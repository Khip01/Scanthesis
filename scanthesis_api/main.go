package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

// APIClient holds the API configuration.
type APIClient struct {
	apiKey  string
	modelID string
}

// NewAPIClient creates a new API client.
func NewAPIClient(apiKey, modelID string) *APIClient {
	return &APIClient{apiKey: apiKey, modelID: modelID}
}

func (c *APIClient) SetModel(modelID string) { c.modelID = modelID }
func (c *APIClient) GetModelID() string      { return c.modelID }
func (c *APIClient) SetAPIKey(apiKey string) { c.apiKey = apiKey }
func (c *APIClient) GetAPIKey() string       { return maskAPIKey(c.apiKey) }
func (c *APIClient) GetRawAPIKey() string    { return c.apiKey }

func maskAPIKey(key string) string {
	if len(key) > 8 {
		return key[:4] + "..." + key[len(key)-4:]
	}
	return key
}

func main() {
	endpointFlag := flag.String("endpoint", "", "API endpoint (e.g., localhost:8080)")
	apiKeyFlag := flag.String("api_key", "", "API key for Gemini")
	flag.Parse()

	endpoint := *endpointFlag
	apiKey := *apiKeyFlag

	if endpoint == "" {
		fmt.Println("Error: --endpoint argument is required")
		return
	}
	if apiKey == "" {
		fmt.Println("Error: --api_key argument is required")
		return
	}

	client := NewAPIClient(apiKey, "gemini-2.5-flash")

	// Check if the API is already running
	resp, err := http.Get(endpoint + "/")
	if err == nil && resp.StatusCode == http.StatusOK {
		fmt.Println("API already running on " + endpoint + "/")
		return
	}

	clearScreen()
	fmt.Println("Starting server...")
	http.HandleFunc("/api/ocr", func(w http.ResponseWriter, r *http.Request) {
		GeminiHandler(w, r, client)
	})
	http.HandleFunc("/api/check", APICheck)

	// Start server in background
	go func() {
		port := "8080"
		if idx := strings.LastIndex(endpoint, ":"); idx != -1 {
			portPart := endpoint[idx+1:]
			if slashIdx := strings.Index(portPart, "/"); slashIdx != -1 {
				port = portPart[:slashIdx]
			} else {
				port = portPart
			}
		}
		http.ListenAndServe(":"+port, nil)
	}()

	// Run interactive menu
	runMenu(client, endpoint)
}

func runMenu(client *APIClient, endpoint string) {
	for {
		clearScreen()
		printMainMenu(client, endpoint)

		fmt.Print("  > Select option: ")
		var choice string
		fmt.Scan(&choice)

		switch choice {
		case "1":
			handleChangeAPIKey(client)
		case "2":
			handleTestConnection(client)
		case "3":
			handleChangeModel(client)
		case "4":
			clearScreen()
			fmt.Println()
			fmt.Println("  Goodbye!")
			fmt.Println()
			return
		default:
			fmt.Println()
			fmt.Println("  Invalid option. Please enter 1-4.")
			fmt.Println()
			fmt.Print("  Press Enter to continue...")
			fmt.Scanln()
		}
	}
}

func printMainMenu(client *APIClient, endpoint string) {
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    SCANTHESIS API SERVER                     ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("  API Endpoint : %s\n", endpoint)
	fmt.Printf("  API Key      : %s\n", client.GetAPIKey())
	fmt.Println()
	fmt.Printf("  Current Model: %s\n", client.GetModelID())
	fmt.Println()
	fmt.Println("  ─────────────────────────────────────────────────────────────────")
	fmt.Println("   [1] Change API Key")
	fmt.Println("   [2] Test Connection")
	fmt.Println("   [3] Change Model")
	fmt.Println("   [4] Exit")
	fmt.Println()
}

func handleChangeAPIKey(client *APIClient) {
	clearScreen()
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                    CHANGE API KEY                             ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("  Current API Key: %s\n", client.GetAPIKey())
	fmt.Println()
	fmt.Println("  Enter new API Key (or 'c' to cancel):")
	fmt.Print("  > ")

	var input string
	fmt.Scan(&input)

	if strings.ToLower(input) == "c" {
		fmt.Println()
		fmt.Println("  Cancelled.")
	} else if len(input) > 10 {
		client.SetAPIKey(input)
		fmt.Println()
		fmt.Println("  API Key updated successfully!")
	} else {
		fmt.Println()
		fmt.Println("  API key must be at least 10 characters.")
	}

	fmt.Print("  Press Enter to continue...")
	fmt.Scanln()
}

func handleTestConnection(client *APIClient) {
	clearScreen()
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════╗")
	fmt.Println("║                   TEST CONNECTION                            ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("  Testing connection to Gemini API...\n")
	fmt.Printf("  Model: %s\n", client.GetModelID())
	fmt.Println()
	fmt.Println("  Connecting...")

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	msg, err := testGeminiConnection(ctx, client)
	if err != nil {
		fmt.Println()
		fmt.Printf("  [FAILED] %s\n", err.Error())
	} else {
		fmt.Println()
		fmt.Printf("  [SUCCESS] %s\n", msg)
	}

	fmt.Println()
	fmt.Print("  Press Enter to continue...")
	fmt.Scanln()
}

func handleChangeModel(client *APIClient) {
	clearScreen()
	fmt.Println()
	fmt.Println("╔══════════════════════════════════════════════════════════════════════════════════════╗")
	fmt.Println("║                                 GEMINI MODEL BROWSER                                 ║")
	fmt.Println("╚══════════════════════════════════════════════════════════════════════════════════════╝")
	fmt.Println()
	fmt.Printf("  Current: %s\n", client.GetModelID())
	fmt.Println()

	// Get available models from API
	models, err := listGeminiModels(client)
	if err != nil {
		fmt.Printf("  Failed to fetch models: %s\n", err.Error())
		fmt.Print("  Press Enter to continue...")
		fmt.Scanln()
		return
	}

	// Header
	fmt.Printf("  %-4s %-40s %-18s %-18s %-25s\n", "ID", "MODEL NAME", "CONTEXT (In/Out)", "THINKING", "CAPABILITIES")
	fmt.Println("  ─── ──────────────────────────────────────── ───────────────── ─────────────── ──────────────────────────────────────────────────")

	// Format capabilities - shorten method names
	formatCap := func(methods []string) string {
		result := ""
		for _, m := range methods {
			switch m {
			case "generateContent":
				result += "gen, "
			case "countTokens":
				result += "count, "
			case "createCachedContent":
				result += "cache, "
			case "batchGenerateContent":
				result += "batch, "
			default:
				result += m + ", "
			}
		}
		return strings.TrimSuffix(result, ", ")
	}

	hasGenerateContent := func(methods []string) bool {
		for _, m := range methods {
			if m == "generateContent" {
				return true
			}
		}
		return false
	}

	// Format context size
	formatContext := func(in, out int) string {
		formatNum := func(n int) string {
			switch {
			case n >= 1000000:
				return fmt.Sprintf("%dM", n/1000000)
			case n >= 1000:
				return fmt.Sprintf("%dk", n/1000)
			default:
				return fmt.Sprintf("%d", n)
			}
		}
		return formatNum(in) + " / " + formatNum(out)
	}

	for i, m := range models {
		marker := " "
		if m.Name == client.GetModelID() {
			marker = "●"
		}
		modelShort := strings.TrimPrefix(m.Name, "models/")
		cap := formatCap(m.SupportedGenerationMethods)
		ctx := formatContext(m.InputTokenLimit, m.OutputTokenLimit)
		think := "-"
		if m.Thinking != nil && *m.Thinking {
			think = "Yes"
		}
		imgSupport := ""
		if hasGenerateContent(m.SupportedGenerationMethods) {
			imgSupport = "(img)"
		}
		fmt.Printf("  %02d %s %-40s %-16s %-16s %-24s\n", i+1, marker, modelShort, ctx, think, cap+" "+imgSupport)
	}
	fmt.Println("  ─── ──────────────────────────────────────── ───────────────── ─────────────── ──────────────────────────────────────────────────")
	fmt.Println("  (img) = supports image attachment")
	fmt.Println()
	fmt.Print("  > Enter model number (or 'c' to cancel): ")

	var input string
	fmt.Scan(&input)

	if strings.ToLower(input) == "c" {
		fmt.Println()
		fmt.Println("  Cancelled.")
	} else {
		var num int
		if _, err := fmt.Sscanf(input, "%d", &num); err == nil && num >= 1 && num <= len(models) {
			selected := models[num-1]
			client.SetModel(selected.Name)
			fmt.Println()
			fmt.Printf("  Model changed to: %s\n", selected.Name)
		} else {
			fmt.Println()
			fmt.Println("  Invalid selection.")
		}
	}

	fmt.Print("  Press Enter to continue...")
	fmt.Scanln()
}

// listGeminiModels fetches available models from Gemini API.
func listGeminiModels(client *APIClient) ([]ModelInfo, error) {
	url := "https://generativelanguage.googleapis.com/v1beta/models?key=" + client.GetRawAPIKey()
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("API returned status %d", resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var result struct {
		Models []ModelInfo `json:"models"`
	}
	if err := json.Unmarshal(body, &result); err != nil {
		return nil, err
	}

	return result.Models, nil
}

// ModelInfo represents a Gemini model from the API.
type ModelInfo struct {
	Name                       string   `json:"name"`
	DisplayName                string   `json:"displayName"`
	Description                string   `json:"description"`
	SupportedGenerationMethods []string `json:"supportedGenerationMethods"`
	InputTokenLimit            int      `json:"inputTokenLimit"`
	OutputTokenLimit           int      `json:"outputTokenLimit"`
	Thinking                   *bool    `json:"thinking"`
}

// testGeminiConnection tests the connection to Gemini API.
func testGeminiConnection(ctx context.Context, client *APIClient) (string, error) {
	if client.GetRawAPIKey() == "" {
		return "", fmt.Errorf("API key is required")
	}

	genClient, err := genai.NewClient(ctx, option.WithAPIKey(client.GetRawAPIKey()))
	if err != nil {
		return "", err
	}
	defer genClient.Close()

	model := genClient.GenerativeModel(client.GetModelID())
	req := []genai.Part{genai.Text("Reply with 'OK' if you receive this message.")}
	_, err = model.GenerateContent(ctx, req...)
	if err != nil {
		return "", err
	}

	return "Connection successful!", nil
}

func clearScreen() {
	fmt.Print("\033[2J\033[H")
}

func GeminiHandler(w http.ResponseWriter, r *http.Request, client *APIClient) {
	ctx := context.Background()

	err := r.ParseMultipartForm(50 << 20)
	if err != nil {
		http.Error(w, "Failed to parse form: "+err.Error(), http.StatusBadRequest)
		return
	}

	files := r.MultipartForm.File["images"]
	if len(files) == 0 {
		http.Error(w, "No images provided", http.StatusBadRequest)
		return
	}

	genClient, err := genai.NewClient(ctx, option.WithAPIKey(client.GetRawAPIKey()))
	if err != nil {
		http.Error(w, "Failed to create Gemini client: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer genClient.Close()

	model := genClient.GenerativeModel(client.GetModelID())

	prompt := "Perform OCR on this image. Extract only the code and comments exactly as seen, without any explanation or additional content. Ensure the code is cleanly formatted and properly indented."

	if customPrompt := r.FormValue("prompt"); customPrompt != "" {
		prompt = customPrompt
	}

	req := []genai.Part{genai.Text(prompt)}
	for _, fileHeader := range files {
		file, err := fileHeader.Open()
		if err != nil {
			http.Error(w, "Failed to open image: "+err.Error(), http.StatusInternalServerError)
			return
		}
		imgBytes, err := io.ReadAll(file)
		file.Close()
		if err != nil {
			http.Error(w, "Failed to read image: "+err.Error(), http.StatusInternalServerError)
			return
		}
		req = append(req, genai.ImageData("png", imgBytes))
	}

	res, err := model.GenerateContent(ctx, req...)
	if err != nil {
		http.Error(w, "Failed to generate content: "+err.Error(), http.StatusInternalServerError)
		return
	}

	var output string
	for _, cand := range res.Candidates {
		for _, part := range cand.Content.Parts {
			if text, ok := part.(genai.Text); ok {
				output += string(text)
			}
		}
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]string{"response": output})
}

func APICheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "You good to go!")
}
