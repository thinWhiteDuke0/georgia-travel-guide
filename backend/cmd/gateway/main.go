package main

import (
	"log"
	"net/http"

	"georgia-travel-guide/internal/config"
	"georgia-travel-guide/internal/gateway"
)

func main() {
	srv := &gateway.Server{
		Clients:   gateway.NewClients(),
		JWTSecret: config.Getenv("JWT_SECRET", "dev-only-insecure-secret-change-me-32bytes-min"),
	}
	addr := ":" + config.Getenv("PORT", "8080")
	log.Println("api gateway listening on", addr)
	log.Fatal(http.ListenAndServe(addr, srv.Router()))
}
