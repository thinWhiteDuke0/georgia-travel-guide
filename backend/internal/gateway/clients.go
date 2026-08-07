package gateway

import (
	"log"

	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"

	"georgia-travel-guide/internal/config"
	authpb "georgia-travel-guide/internal/pb/auth"
	citypb "georgia-travel-guide/internal/pb/city"
	favpb "georgia-travel-guide/internal/pb/favorite"
	placespb "georgia-travel-guide/internal/pb/places"
	routepb "georgia-travel-guide/internal/pb/route"
)

// Clients holds one gRPC client per downstream microservice.
type Clients struct {
	Auth     authpb.AuthServiceClient
	City     citypb.CityServiceClient
	Places   placespb.PlacesServiceClient
	Route    routepb.RouteServiceClient
	Favorite favpb.FavoriteServiceClient
}

func dial(addr string) *grpc.ClientConn {
	conn, err := grpc.NewClient(addr, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		log.Fatalf("dial %s: %v", addr, err)
	}
	return conn
}

// NewClients connects to every microservice using addresses from env.
func NewClients() *Clients {
	return &Clients{
		Auth:     authpb.NewAuthServiceClient(dial(config.Getenv("AUTH_ADDR", "auth:5001"))),
		City:     citypb.NewCityServiceClient(dial(config.Getenv("CITY_ADDR", "city:5002"))),
		Places:   placespb.NewPlacesServiceClient(dial(config.Getenv("PLACES_ADDR", "places:5003"))),
		Route:    routepb.NewRouteServiceClient(dial(config.Getenv("ROUTE_ADDR", "route:5004"))),
		Favorite: favpb.NewFavoriteServiceClient(dial(config.Getenv("FAVORITE_ADDR", "favorite:5005"))),
	}
}
