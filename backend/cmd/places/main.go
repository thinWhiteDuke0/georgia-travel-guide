package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"

	"georgia-travel-guide/internal/config"
	"georgia-travel-guide/internal/db"
	pb "georgia-travel-guide/internal/pb/places"
	"georgia-travel-guide/internal/places"
)

func main() {
	ctx := context.Background()
	pool := db.Connect(ctx, config.DatabaseURL())
	defer pool.Close()

	addr := ":" + config.Getenv("PORT", "5003")
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatal(err)
	}
	s := grpc.NewServer()
	pb.RegisterPlacesServiceServer(s, &places.Server{DB: pool})
	log.Println("places service listening on", addr)
	log.Fatal(s.Serve(lis))
}
