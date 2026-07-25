package config

import (
    "log"
    "os"

    "github.com/joho/godotenv"
)

// Config holds all environment-driven configuration.
type Config struct {
    Port         string
    DatabaseURL  string
    JWTSecret    string
    GroqAPIKey   string
    GroqModel    string
}

// Load reads configuration from environment variables with sensible defaults.
// It attempts to load a .env file first (if present) for local development.
func Load() *Config {
    if err := godotenv.Load(); err != nil {
        log.Println("no .env file found, relying on system environment variables")
    }

   return &Config{
		Port:         getEnv("PORT", "8080"),
		DatabaseURL:  getEnv("DATABASE_URL", ""),
		JWTSecret:    getEnv("JWT_SECRET", "change-me-in-production"),
		GroqAPIKey:   getEnv("GROQ_API_KEY", ""),
		GroqModel:    getEnv("GROQ_MODEL", "llama-3.3-70b-versatile"),
	}
}

func getEnv(key, fallback string) string {
    if v := os.Getenv(key); v != "" {
        return v
    }
    return fallback
}
