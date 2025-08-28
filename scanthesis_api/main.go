package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"strings"

	"github.com/google/generative-ai-go/genai"
	"google.golang.org/api/option"
)

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

	// Check if the API is already running
	resp, err := http.Get(endpoint + "/")
	if err == nil && resp.StatusCode == http.StatusOK {
		fmt.Println("API already running on " + endpoint + "/")
		return
	}

	http.HandleFunc("/api/ocr", func(w http.ResponseWriter, r *http.Request) {
		GeminiHandler(w, r, apiKey)
	})
	http.HandleFunc("/api/check", APICheck)

	fmt.Println("Server started on " + endpoint + "/ ...")

	port := "8080" // default
	if idx := strings.LastIndex(endpoint, ":"); idx != -1 {
		portPart := endpoint[idx+1:]
		if slashIdx := strings.Index(portPart, "/"); slashIdx != -1 {
			port = portPart[:slashIdx]
		} else {
			port = portPart
		}
	}
	err = http.ListenAndServe(":"+port, nil)
	if err != nil {
		fmt.Println("Failed to start server:", err)
	}
}

func GeminiHandler(w http.ResponseWriter, r *http.Request, apiKey string) {
	context := context.Background()
	if apiKey == "" {
		http.Error(w, "API_KEY argument is required", http.StatusInternalServerError)
		return
	}

	err := r.ParseMultipartForm(50 << 20) // 50 MB limit total image file
	if err != nil {
		http.Error(w, "Failed to parse form: "+err.Error(), http.StatusBadRequest)
		return
	}

	files := r.MultipartForm.File["images"]
	if len(files) == 0 {
		http.Error(w, "No images provided", http.StatusBadRequest)
		return
	}

	client, err := genai.NewClient(context, option.WithAPIKey(apiKey))
	if err != nil {
		http.Error(w, "Failed to create Gemini client: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer client.Close()

	model := client.GenerativeModel("gemini-1.5-flash")

	prompt := "Perform OCR on this image. Extract only the code and comments exactly as seen, without any explanation or additional content. Ensure the code is cleanly formatted and properly indented."

	customPrompt := r.FormValue("prompt")
	if customPrompt != "" {
		prompt = customPrompt
	}

	req := []genai.Part{
		genai.Text(prompt),
	}

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

		req = append(req, genai.ImageData("image/png", imgBytes))
	}

	res, err := model.GenerateContent(context, req...)
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

	result := map[string]string{
		"response": output,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)
}

func APICheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "You good to go!")
}
