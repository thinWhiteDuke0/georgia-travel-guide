// Command server runs the API gateway together with every Go microservice
// inside a single process.
//
// This exists purely for constrained hosting (the free Render tier allows
// only a couple of always-on services). The service code is unchanged and
// still communicates over gRPC — the difference is that the gRPC listeners
// are bound to localhost inside one container instead of separate ones.
// docker-compose.yml still runs each service on its own, which is the
// arrangement described in the thesis.
package main

import (
	"context"
	"embed"
	"log"
	"net"
	"net/http"
	"os"
	"strings"

	"google.golang.org/grpc"

	"georgia-travel-guide/internal/city"
	"georgia-travel-guide/internal/config"
	"georgia-travel-guide/internal/db"
	"georgia-travel-guide/internal/favorite"
	"georgia-travel-guide/internal/gateway"
	citypb "georgia-travel-guide/internal/pb/city"
	favpb "georgia-travel-guide/internal/pb/favorite"
	placespb "georgia-travel-guide/internal/pb/places"
	routepb "georgia-travel-guide/internal/pb/route"
	"georgia-travel-guide/internal/places"
	"georgia-travel-guide/internal/route"

	"github.com/jackc/pgx/v5"
)

//go:embed all:migrations
var migrations embed.FS

func main() {
	ctx := context.Background()
	pool := db.Connect(ctx, config.DatabaseURL())
	defer pool.Close()

	// Managed databases start empty, so apply the schema and seed on boot.
	if config.Getenv("RUN_MIGRATIONS", "true") == "true" {
		applySQL(ctx, "migrations/001_init.sql")
		if config.Getenv("RUN_SEED", "true") == "true" {
			applySQL(ctx, "migrations/seed.sql")
		}
	}

	// Each service keeps its own gRPC server, bound to loopback.
	serve := func(port string, register func(*grpc.Server)) {
		lis, err := net.Listen("tcp", "127.0.0.1:"+port)
		if err != nil {
			log.Fatalf("listen %s: %v", port, err)
		}
		s := grpc.NewServer()
		register(s)
		go func() {
			if err := s.Serve(lis); err != nil {
				log.Fatalf("serve %s: %v", port, err)
			}
		}()
		log.Println("internal gRPC service listening on", port)
	}

	serve("5002", func(s *grpc.Server) { citypb.RegisterCityServiceServer(s, &city.Server{DB: pool}) })
	serve("5003", func(s *grpc.Server) { placespb.RegisterPlacesServiceServer(s, &places.Server{DB: pool}) })
	serve("5004", func(s *grpc.Server) { routepb.RegisterRouteServiceServer(s, &route.Server{DB: pool}) })
	serve("5005", func(s *grpc.Server) { favpb.RegisterFavoriteServiceServer(s, &favorite.Server{DB: pool}) })

	// Point the gateway at the loopback listeners unless overridden.
	setDefault("CITY_ADDR", "127.0.0.1:5002")
	setDefault("PLACES_ADDR", "127.0.0.1:5003")
	setDefault("ROUTE_ADDR", "127.0.0.1:5004")
	setDefault("FAVORITE_ADDR", "127.0.0.1:5005")

	srv := &gateway.Server{
		Clients:   gateway.NewClients(),
		JWTSecret: config.Getenv("JWT_SECRET", "dev-only-insecure-secret-change-me-32bytes-min"),
	}

	addr := ":" + config.Getenv("PORT", "8080")
	log.Println("api gateway listening on", addr)
	log.Fatal(http.ListenAndServe(addr, srv.Router()))
}

func setDefault(key, value string) {
	if os.Getenv(key) == "" {
		_ = os.Setenv(key, value)
	}
}

// applySQL runs an embedded SQL file.
//
// It opens its own connection in simple-query mode: these files contain many
// statements, and pgx's default extended protocol only accepts one statement
// per call. The SQL is written to be idempotent, so restarts are harmless.
func applySQL(ctx context.Context, name string) {
	body, err := migrations.ReadFile(name)
	if err != nil {
		log.Printf("skipping %s: %v", name, err)
		return
	}

	cfg, err := pgx.ParseConfig(config.DatabaseURL())
	if err != nil {
		log.Printf("migration config: %v", err)
		return
	}
	cfg.DefaultQueryExecMode = pgx.QueryExecModeSimpleProtocol

	conn, err := pgx.ConnectConfig(ctx, cfg)
	if err != nil {
		log.Printf("migration connect: %v", err)
		return
	}
	defer conn.Close(ctx)

	if _, err := conn.Exec(ctx, string(body)); err != nil {
		if strings.Contains(err.Error(), "already exists") {
			log.Printf("%s: already applied", name)
			return
		}
		log.Printf("warning applying %s: %v", name, err)
		return
	}
	log.Printf("applied %s", name)
}
