package ai

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"time"

	"ai-mentor-backend/internal/usecase"
)

type groqProvider struct {
	apiKey string
	model  string
	client *http.Client
}

func NewGroqProvider(apiKey, model string) *groqProvider {
	return &groqProvider{
		apiKey: apiKey,
		model:  model,
		client: &http.Client{Timeout: 30 * time.Second},
	}
}

type groqChatRequest struct {
	Model    string            `json:"model"`
	Messages []groqChatMessage `json:"messages"`
}

type groqChatMessage struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type groqChatResponse struct {
	Choices []struct {
		Message groqChatMessage `json:"message"`
	} `json:"choices"`
}

// GenerateReply sends the full conversation (system prompt + trimmed
// history + latest user message, in order) to Groq's chat-completions
// endpoint and returns the assistant's reply text.
func (p *groqProvider) GenerateReply(ctx context.Context, messages []usecase.ChatMessage) (string, error) {
	groqMessages := make([]groqChatMessage, 0, len(messages))
	for _, m := range messages {
		groqMessages = append(groqMessages, groqChatMessage{Role: m.Role, Content: m.Content})
	}

	reqBody := groqChatRequest{
		Model:    p.model,
		Messages: groqMessages,
	}

	body, err := json.Marshal(reqBody)
	if err != nil {
		return "", fmt.Errorf("marshal request: %w", err)
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodPost, "https://api.groq.com/openai/v1/chat/completions", bytes.NewReader(body))
	if err != nil {
		return "", fmt.Errorf("build request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+p.apiKey)

	resp, err := p.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("call groq: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(resp.Body)
		return "", fmt.Errorf("groq returned status %d: %s", resp.StatusCode, string(b))
	}

	var parsed groqChatResponse
	if err := json.NewDecoder(resp.Body).Decode(&parsed); err != nil {
		return "", fmt.Errorf("decode response: %w", err)
	}
	if len(parsed.Choices) == 0 {
		return "", fmt.Errorf("empty response from groq")
	}

	return parsed.Choices[0].Message.Content, nil
}