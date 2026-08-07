package favorite

import (
	"context"

	pb "georgia-travel-guide/internal/pb/favorite"
	"github.com/jackc/pgx/v5/pgxpool"
)

type Server struct {
	pb.UnimplementedFavoriteServiceServer
	DB *pgxpool.Pool
}

func (s *Server) AddFavorite(ctx context.Context, r *pb.AddFavoriteRequest) (*pb.Favorite, error) {
	f := &pb.Favorite{}
	err := s.DB.QueryRow(ctx,
		`INSERT INTO favorites (user_id, entity_type, entity_id)
		 VALUES ($1,$2,$3)
		 ON CONFLICT (user_id, entity_type, entity_id) DO UPDATE SET entity_id = EXCLUDED.entity_id
		 RETURNING id, user_id, entity_type, entity_id`,
		r.GetUserId(), r.GetEntityType(), r.GetEntityId()).
		Scan(&f.Id, &f.UserId, &f.EntityType, &f.EntityId)
	if err != nil {
		return nil, err
	}
	return f, nil
}

func (s *Server) RemoveFavorite(ctx context.Context, r *pb.RemoveFavoriteRequest) (*pb.Empty, error) {
	_, err := s.DB.Exec(ctx,
		`DELETE FROM favorites WHERE user_id=$1 AND entity_type=$2 AND entity_id=$3`,
		r.GetUserId(), r.GetEntityType(), r.GetEntityId())
	return &pb.Empty{}, err
}

func (s *Server) ListFavorites(ctx context.Context, r *pb.ListFavoritesRequest) (*pb.ListFavoritesResponse, error) {
	rows, err := s.DB.Query(ctx,
		`SELECT id, user_id, entity_type, entity_id FROM favorites WHERE user_id=$1 ORDER BY created_at DESC`,
		r.GetUserId())
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := &pb.ListFavoritesResponse{}
	for rows.Next() {
		f := &pb.Favorite{}
		if err := rows.Scan(&f.Id, &f.UserId, &f.EntityType, &f.EntityId); err != nil {
			return nil, err
		}
		out.Favorites = append(out.Favorites, f)
	}
	return out, rows.Err()
}
