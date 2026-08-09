package config

import "os"

// Getenv returns the env var or a fallback default.
func Getenv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

// DatabaseURL builds a libpq/pgx connection string from env (or DATABASE_URL).
func DatabaseURL() string {
	if v := os.Getenv("DATABASE_URL"); v != "" {
		return v
	}
	host := Getenv("DB_HOST", "postgres")
	port := Getenv("DB_PORT", "5432")
	user := Getenv("DB_USER", "guide")
	pass := Getenv("DB_PASSWORD", "guide")
	name := Getenv("DB_NAME", "guide")
	return "postgres://" + user + ":" + pass + "@" + host + ":" + port + "/" + name + "?sslmode=disable"
}
