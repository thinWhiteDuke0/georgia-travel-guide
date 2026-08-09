package jwt

import (
	"errors"
	"strconv"

	jwtlib "github.com/golang-jwt/jwt/v5"
)

// Verify parses an HS256 token signed by the auth service and returns the user id (sub claim).
func Verify(tokenStr, secret string) (int64, error) {
	token, err := jwtlib.Parse(tokenStr, func(t *jwtlib.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwtlib.SigningMethodHMAC); !ok {
			return nil, errors.New("unexpected signing method")
		}
		return []byte(secret), nil
	})
	if err != nil || !token.Valid {
		return 0, errors.New("invalid token")
	}
	claims, ok := token.Claims.(jwtlib.MapClaims)
	if !ok {
		return 0, errors.New("invalid claims")
	}
	sub, ok := claims["sub"]
	if !ok {
		return 0, errors.New("missing sub")
	}
	switch v := sub.(type) {
	case string:
		return strconv.ParseInt(v, 10, 64)
	case float64:
		return int64(v), nil
	default:
		return 0, errors.New("bad sub type")
	}
}
