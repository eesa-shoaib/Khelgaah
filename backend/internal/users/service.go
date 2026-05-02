package users

import "context"

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Me(ctx context.Context, userID int64) (MeResponse, error) {
	user, err := s.repo.FindByID(ctx, userID)
	if err != nil {
		return MeResponse{}, err
	}

	return MeResponse{
		ID:       user.ID,
		FullName: user.FullName,
		Email:    user.Email,
		Phone:    user.Phone,
		Role:     user.Role,
		Status:   user.Status,
	}, nil
}
