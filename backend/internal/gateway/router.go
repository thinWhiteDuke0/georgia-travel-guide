package gateway

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

// Server is the API Gateway: REST in, gRPC out.
type Server struct {
	Clients   *Clients
	JWTSecret string
}

// Router wires all REST endpoints (see thesis appendix B).
func (s *Server) Router() http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(middleware.Recoverer)
	r.Use(corsMiddleware)

	r.Get("/health", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, http.StatusOK, map[string]string{"status": "ok"})
	})

	r.Route("/api", func(api chi.Router) {
		// public auth
		api.Post("/auth/register", s.Register)
		api.Post("/auth/login", s.Login)
		api.Post("/auth/refresh", s.Refresh)

		// public catalogue
		api.Get("/cities", s.ListCities)
		api.Get("/cities/{id}", s.GetCity)
		api.Get("/cities/{id}/attractions", s.CityAttractions)
		api.Get("/cities/{id}/restaurants", s.CityRestaurants)
		api.Get("/cities/{id}/hotels", s.CityHotels)
		api.Get("/routes", s.ListRoutes)
		api.Get("/routes/{id}", s.GetRoute)

		// protected
		api.Group(func(p chi.Router) {
			p.Use(s.RequireAuth)
			p.Get("/users/me", s.GetMe)
			p.Put("/users/me", s.UpdateMe)
			p.Get("/favorites", s.ListFavorites)
			p.Post("/favorites", s.AddFavorite)
			p.Delete("/favorites", s.RemoveFavorite)
		})
	})
	return r
}

func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET,POST,PUT,DELETE,OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "Authorization,Content-Type")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
