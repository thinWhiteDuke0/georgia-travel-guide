package route

import (
	"context"

	pb "georgia-travel-guide/internal/pb/route"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Server struct {
	pb.UnimplementedRouteServiceServer
	DB *pgxpool.Pool
}

func scanRoute(row interface{ Scan(...any) error }) (*pb.Route, error) {
	r := &pb.Route{}
	err := row.Scan(&r.Id, &r.CityId, &r.Title, &r.Description, &r.DurationHours, &r.Difficulty)
	return r, err
}

func (s *Server) ListRoutes(ctx context.Context, req *pb.ListRoutesRequest) (*pb.ListRoutesResponse, error) {
	q := `SELECT id, city_id, title, description, duration_hours, difficulty FROM routes`
	var rows interface {
		Next() bool
		Scan(...any) error
		Close()
		Err() error
	}
	var err error
	if req.GetCityId() > 0 {
		rows, err = s.DB.Query(ctx, q+` WHERE city_id=$1 ORDER BY title`, req.GetCityId())
	} else {
		rows, err = s.DB.Query(ctx, q+` ORDER BY title`)
	}
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := &pb.ListRoutesResponse{}
	for rows.Next() {
		r, err := scanRoute(rows)
		if err != nil {
			return nil, err
		}
		out.Routes = append(out.Routes, r)
	}
	return out, rows.Err()
}

func (s *Server) GetRoute(ctx context.Context, req *pb.GetRouteRequest) (*pb.Route, error) {
	return scanRoute(s.DB.QueryRow(ctx,
		`SELECT id, city_id, title, description, duration_hours, difficulty FROM routes WHERE id=$1`,
		req.GetId()))
}
