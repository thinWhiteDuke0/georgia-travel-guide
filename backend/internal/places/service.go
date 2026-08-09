package places

import (
	"context"

	pb "georgia-travel-guide/internal/pb/places"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Server struct {
	pb.UnimplementedPlacesServiceServer
	DB *pgxpool.Pool
}

func (s *Server) ListAttractions(ctx context.Context, r *pb.CityIdRequest) (*pb.ListAttractionsResponse, error) {
	rows, err := s.DB.Query(ctx,
		`SELECT id, city_id, name, category, description, latitude, longitude
		 FROM attractions WHERE city_id=$1 ORDER BY name`, r.GetCityId())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := &pb.ListAttractionsResponse{}
	for rows.Next() {
		a := &pb.Attraction{}
		if err := rows.Scan(&a.Id, &a.CityId, &a.Name, &a.Category, &a.Description, &a.Latitude, &a.Longitude); err != nil {
			return nil, err
		}
		out.Attractions = append(out.Attractions, a)
	}
	return out, rows.Err()
}

func (s *Server) ListRestaurants(ctx context.Context, r *pb.CityIdRequest) (*pb.ListRestaurantsResponse, error) {
	rows, err := s.DB.Query(ctx,
		`SELECT id, city_id, name, cuisine, price_level, address, latitude, longitude
		 FROM restaurants WHERE city_id=$1 ORDER BY name`, r.GetCityId())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := &pb.ListRestaurantsResponse{}
	for rows.Next() {
		x := &pb.Restaurant{}
		if err := rows.Scan(&x.Id, &x.CityId, &x.Name, &x.Cuisine, &x.PriceLevel, &x.Address, &x.Latitude, &x.Longitude); err != nil {
			return nil, err
		}
		out.Restaurants = append(out.Restaurants, x)
	}
	return out, rows.Err()
}

func (s *Server) ListHotels(ctx context.Context, r *pb.CityIdRequest) (*pb.ListHotelsResponse, error) {
	rows, err := s.DB.Query(ctx,
		`SELECT id, city_id, name, stars, address, latitude, longitude
		 FROM hotels WHERE city_id=$1 ORDER BY stars DESC, name`, r.GetCityId())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := &pb.ListHotelsResponse{}
	for rows.Next() {
		h := &pb.Hotel{}
		if err := rows.Scan(&h.Id, &h.CityId, &h.Name, &h.Stars, &h.Address, &h.Latitude, &h.Longitude); err != nil {
			return nil, err
		}
		out.Hotels = append(out.Hotels, h)
	}
	return out, rows.Err()
}
