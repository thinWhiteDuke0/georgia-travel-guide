package main

import (
	"context"
	"log"
	"net"

	"google.golang.org/grpc"

	"georgia-travel-guide/internal/config"
	"georgia-travel-guide/internal/db"
	"georgia-travel-guide/internal/favorite"
	pb "georgia-travel-guide/internal/pb/favorite"
)

func main() {
	ctx := context.Background()
	pool := db.Connect(ctx, config.DatabaseURL())
	defer pool.Close()

	addr := ":" + config.Getenv("PORT", "5005")
	lis, err := net.Listen("tcp", addr)
	if err != nil {
		log.Fatal(err)
	}
	s := grpc.NewServer()
	pb.RegisterFavoriteServiceServer(s, &favorite.Server{DB: pool})
	log.Println("favorite service listening on", addr)
	log.Fatal(s.Serve(lis))
}
