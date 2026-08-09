package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"

	"georgia-travel-guide/internal/config"
	"georgia-travel-guide/internal/db"
	pb "georgia-travel-guide/internal/pb/route"
	"georgia-travel-guide/internal/route"
)

func main() {
	ctx := context.Background()
	pool := db.Connect(ctx, config.DatabaseURL())
	defer pool.Close()

	addr := ":" + config.Getenv("PORT", "5004")
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatal(err)
	}
	s := grpc.NewServer()
	pb.RegisterRouteServiceServer(s, &route.Server{DB: pool})
	log.Println("route service listening on", addr)
	log.Fatal(s.Serve(lis))
}
