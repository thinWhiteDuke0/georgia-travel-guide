package gateway

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"

	authpb "georgia-travel-guide/internal/pb/auth"
	citypb "georgia-travel-guide/internal/pb/city"
	favpb "georgia-travel-guide/internal/pb/favorite"
	placespb "georgia-travel-guide/internal/pb/places"
	routepb "georgia-travel-guide/internal/pb/route"
)

func pathID(r *http.Request, key string) int64 {
	id, _ := strconv.ParseInt(chi.URLParam(r, key), 10, 64)
	return id
}

// ---- auth ----

func (s *Server) Register(w http.ResponseWriter, r *http.Request) {
	var in authpb.RegisterRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	resp, err := s.Clients.Auth.Register(r.Context(), &in)
	if err != nil {
		writeErr(w, http.StatusConflict, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, resp)
}

func (s *Server) Login(w http.ResponseWriter, r *http.Request) {
	var in authpb.LoginRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	resp, err := s.Clients.Auth.Login(r.Context(), &in)
	if err != nil {
		writeErr(w, http.StatusUnauthorized, "invalid credentials")
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) Refresh(w http.ResponseWriter, r *http.Request) {
	var in authpb.RefreshRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	resp, err := s.Clients.Auth.Refresh(r.Context(), &in)
	if err != nil {
		writeErr(w, http.StatusUnauthorized, "invalid refresh token")
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) GetMe(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Auth.GetProfile(r.Context(), &authpb.GetProfileRequest{UserId: userID(r)})
	if err != nil {
		writeErr(w, http.StatusNotFound, "not found")
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) UpdateMe(w http.ResponseWriter, r *http.Request) {
	var in authpb.UpdateProfileRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	in.UserId = userID(r)
	resp, err := s.Clients.Auth.UpdateProfile(r.Context(), &in)
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

// ---- cities ----

func (s *Server) ListCities(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	page, _ := strconv.Atoi(q.Get("page"))
	size, _ := strconv.Atoi(q.Get("page_size"))
	resp, err := s.Clients.City.ListCities(r.Context(), &citypb.ListCitiesRequest{
		Page: int32(page), PageSize: int32(size), Region: q.Get("region"), Search: q.Get("search"),
	})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) GetCity(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.City.GetCity(r.Context(), &citypb.GetCityRequest{Id: pathID(r, "id")})
	if err != nil {
		writeErr(w, http.StatusNotFound, "city not found")
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) CityAttractions(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Places.ListAttractions(r.Context(), &placespb.CityIdRequest{CityId: pathID(r, "id")})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) CityRestaurants(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Places.ListRestaurants(r.Context(), &placespb.CityIdRequest{CityId: pathID(r, "id")})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) CityHotels(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Places.ListHotels(r.Context(), &placespb.CityIdRequest{CityId: pathID(r, "id")})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

// ---- routes ----

func (s *Server) ListRoutes(w http.ResponseWriter, r *http.Request) {
	cityID, _ := strconv.ParseInt(r.URL.Query().Get("city_id"), 10, 64)
	resp, err := s.Clients.Route.ListRoutes(r.Context(), &routepb.ListRoutesRequest{CityId: cityID})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) GetRoute(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Route.GetRoute(r.Context(), &routepb.GetRouteRequest{Id: pathID(r, "id")})
	if err != nil {
		writeErr(w, http.StatusNotFound, "route not found")
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

// ---- favorites (auth required) ----

func (s *Server) ListFavorites(w http.ResponseWriter, r *http.Request) {
	resp, err := s.Clients.Favorite.ListFavorites(r.Context(), &favpb.ListFavoritesRequest{UserId: userID(r)})
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusOK, resp)
}

func (s *Server) AddFavorite(w http.ResponseWriter, r *http.Request) {
	var in favpb.AddFavoriteRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	in.UserId = userID(r)
	resp, err := s.Clients.Favorite.AddFavorite(r.Context(), &in)
	if err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	writeJSON(w, http.StatusCreated, resp)
}

func (s *Server) RemoveFavorite(w http.ResponseWriter, r *http.Request) {
	var in favpb.RemoveFavoriteRequest
	if decode(r, &in) != nil {
		writeErr(w, http.StatusBadRequest, "invalid body")
		return
	}
	in.UserId = userID(r)
	if _, err := s.Clients.Favorite.RemoveFavorite(r.Context(), &in); err != nil {
		writeErr(w, http.StatusInternalServerError, err.Error())
		return
	}
	w.WriteHeader(http.StatusNoContent)
}
