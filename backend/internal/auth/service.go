package auth

import (
	"context"
	"errors"
	"fmt"
	"net/mail"
	"strings"

	"github.com/eesa/khelgaah/backend/internal/users"
	"golang.org/x/crypto/bcrypt"
)

var ErrInvalidCredentials = errors.New("invalid credentials")
var ErrInvalidSignup = errors.New("invalid signup input")

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
	fullName := strings.TrimSpace(input.FullName)
	email := strings.TrimSpace(strings.ToLower(input.Email))
	phone := strings.TrimSpace(input.Phone)
	role := normalizeSignupRole(input.Role)

	if fullName == "" {
		return AuthResult{}, fmt.Errorf("%w: full_name is required", ErrInvalidSignup)
	}
	if _, err := mail.ParseAddress(email); err != nil {
		return AuthResult{}, fmt.Errorf("%w: email must be valid", ErrInvalidSignup)
	}
	if len(input.Password) < 8 {
		return AuthResult{}, fmt.Errorf("%w: password must be at least 8 characters", ErrInvalidSignup)
	}
	if role == "admin" {
		return AuthResult{}, fmt.Errorf("%w: admin signup is not allowed", ErrInvalidSignup)
	}
	if role != "customer" && role != "venue_owner" {
		return AuthResult{}, fmt.Errorf("%w: unsupported role", ErrInvalidSignup)
	}

	passwordHash, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return AuthResult{}, err
	}

	user, err := s.repo.CreateUser(ctx, CreateUserParams{
		FullName:     fullName,
		Email:        email,
		PasswordHash: string(passwordHash),
		Phone:        phone,
		Role:         role,
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
	if user.Status != "active" {
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
			Role:      user.Role,
			Status:    user.Status,
			CreatedAt: user.CreatedAt,
		},
	}, nil
}

func normalizeSignupRole(raw string) string {
	role := strings.TrimSpace(strings.ToLower(raw))
	if role == "" {
		return "customer"
	}
	return role
}
