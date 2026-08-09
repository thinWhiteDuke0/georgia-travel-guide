package city

import (
	"context"

	pb "georgia-travel-guide/internal/pb/city"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Server struct {
	pb.UnimplementedCityServiceServer
	DB *pgxpool.Pool
}

func (s *Server) ListCities(ctx context.Context, r *pb.ListCitiesRequest) (*pb.ListCitiesResponse, error) {
	page := r.GetPage()
	if page < 1 {
		page = 1
	}
	size := r.GetPageSize()
	if size < 1 || size > 100 {
		size = 20
	}
	offset := (page - 1) * size

	where := "WHERE ($1 = '' OR region = $1) AND ($2 = '' OR name ILIKE '%' || $2 || '%')"
	args := []any{r.GetRegion(), r.GetSearch()}

	var total int32
	if err := s.DB.QueryRow(ctx, "SELECT count(*) FROM cities "+where, args...).Scan(&total); err != nil {
		return nil, err
	}

	rows, err := s.DB.Query(ctx,
		`SELECT id, name, region, description, image_url, latitude, longitude
		 FROM cities `+where+` ORDER BY name LIMIT $3 OFFSET $4`,
		append(args, size, offset)...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	resp := &pb.ListCitiesResponse{Total: total}
	for rows.Next() {
		c := &pb.City{}
		if err := rows.Scan(&c.Id, &c.Name, &c.Region, &c.Description, &c.ImageUrl, &c.Latitude, &c.Longitude); err != nil {
			return nil, err
		}
		resp.Cities = append(resp.Cities, c)
	}
	return resp, rows.Err()
}

func (s *Server) GetCity(ctx context.Context, r *pb.GetCityRequest) (*pb.City, error) {
	c := &pb.City{}
	err := s.DB.QueryRow(ctx,
		`SELECT id, name, region, description, image_url, latitude, longitude
		 FROM cities WHERE id = $1`, r.GetId()).
		Scan(&c.Id, &c.Name, &c.Region, &c.Description, &c.ImageUrl, &c.Latitude, &c.Longitude)
	if err != nil {
		return nil, err
	}
	return c, nil
}
