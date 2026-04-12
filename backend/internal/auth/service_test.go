package auth

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/eesa/khelgaah/backend/internal/users"
)

type authRepoStub struct {
	createUserFn  func(ctx context.Context, params CreateUserParams) (users.User, error)
	findByEmailFn func(ctx context.Context, email string) (users.User, error)
}

func (s authRepoStub) CreateUser(ctx context.Context, params CreateUserParams) (users.User, error) {
	if s.createUserFn == nil {
		return users.User{}, errors.New("unexpected CreateUser call")
	}
	return s.createUserFn(ctx, params)
}

func (s authRepoStub) FindByEmail(ctx context.Context, email string) (users.User, error) {
	if s.findByEmailFn == nil {
		return users.User{}, errors.New("unexpected FindByEmail call")
	}
	return s.findByEmailFn(ctx, email)
}

func TestSignupRejectsInvalidInput(t *testing.T) {
	service := NewService(authRepoStub{}, NewTokenManager("test-secret"))

	_, err := service.Signup(context.Background(), SignupInput{
		FullName: "",
		Email:    "invalid-email",
		Password: "short",
	})
	if !errors.Is(err, ErrInvalidSignup) {
		t.Fatalf("expected ErrInvalidSignup, got %v", err)
	}
}

func TestSignupNormalizesAndCreatesUser(t *testing.T) {
	var gotParams CreateUserParams

	service := NewService(authRepoStub{
		createUserFn: func(_ context.Context, params CreateUserParams) (users.User, error) {
			gotParams = params
			return users.User{
				ID:        42,
				FullName:  params.FullName,
				Email:     params.Email,
				Phone:     params.Phone,
				CreatedAt: time.Unix(1700000000, 0),
			}, nil
		},
	}, NewTokenManager("test-secret"))

	result, err := service.Signup(context.Background(), SignupInput{
		FullName: "  Eesa Shoaib  ",
		Email:    "  EESA@Example.com ",
		Password: "password123",
		Phone:    " 0300-0000000 ",
	})
	if err != nil {
		t.Fatalf("expected signup success, got %v", err)
	}

	if gotParams.FullName != "Eesa Shoaib" {
		t.Fatalf("unexpected full name: %q", gotParams.FullName)
	}
	if gotParams.Email != "eesa@example.com" {
		t.Fatalf("unexpected email: %q", gotParams.Email)
	}
	if gotParams.Phone != "0300-0000000" {
		t.Fatalf("unexpected phone: %q", gotParams.Phone)
	}
	if gotParams.PasswordHash == "" || gotParams.PasswordHash == "password123" {
		t.Fatalf("password hash was not generated")
	}
	if result.Token == "" {
		t.Fatalf("expected token to be issued")
	}
}
