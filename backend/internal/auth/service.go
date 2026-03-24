package auth

import (
	"context"
	"errors"
	"strings"

	"github.com/eesa/khelgaah/backend/internal/users"
	"golang.org/x/crypto/bcrypt"
)

var ErrInvalidCredentials = errors.New("invalid credentials")

type Repository interface {
	CreateUser(ctx context.Context, params CreateUserParams) (users.User, error)
	FindByEmail(ctx context.Context, email string) (users.User, error)
}

type Service struct {
	repo         Repository
	tokenManager *TokenManager
}

func NewService(repo Repository, tokenManager *TokenManager) *Service {
	return &Service{repo: repo, tokenManager: tokenManager}
}

func (s *Service) Signup(ctx context.Context, input SignupInput) (AuthResult, error) {
	passwordHash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return AuthResult{}, err
	}

	user, err := s.repo.CreateUser(ctx, CreateUserParams{
		FullName:     strings.TrimSpace(input.FullName),
		Email:        strings.TrimSpace(strings.ToLower(input.Email)),
		PasswordHash: string(passwordHash),
		Phone:        strings.TrimSpace(input.Phone),
	})
	if err != nil {
		return AuthResult{}, err
	}

	return s.newAuthResult(user)
}

func (s *Service) Login(ctx context.Context, input LoginInput) (AuthResult, error) {
	user, err := s.repo.FindByEmail(ctx, strings.TrimSpace(strings.ToLower(input.Email)))
	if err != nil {
		return AuthResult{}, err
	}

	if bcrypt.CompareHashAndPassword([]byte(user.PasswordHash), []byte(input.Password)) != nil {
		return AuthResult{}, ErrInvalidCredentials
	}

	return s.newAuthResult(user)
}

func (s *Service) newAuthResult(user users.User) (AuthResult, error) {
	token, err := s.tokenManager.Issue(user.ID)
	if err != nil {
		return AuthResult{}, err
	}

	return AuthResult{
		Token: token,
		User: AuthUserDTO{
			ID:        user.ID,
			FullName:  user.FullName,
			Email:     user.Email,
			Phone:     user.Phone,
			CreatedAt: user.CreatedAt,
		},
	}, nil
}
