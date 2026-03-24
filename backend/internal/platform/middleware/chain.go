package middleware

import "net/http"

type Middleware func(http.Handler) http.Handler

func Chain(handler http.Handler, middlewares ...Middleware) http.Handler {
	for i := len(middlewares) - 1; i >= 0; i-- {
		handler = middlewares[i](handler)
	}
	return handler
}

func ChainMux(mux *http.ServeMux, middlewares ...Middleware) http.Handler {
	return Chain(mux, middlewares...)
}
