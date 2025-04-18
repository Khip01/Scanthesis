package main

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"

	"github.com/google/generative-ai-go/genai"
	"github.com/joho/godotenv"
	"google.golang.org/api/option"
)

func main() {

	// Load environment variables from .env file
	err := godotenv.Load()
	if err != nil {
		fmt.Println("Error loading .env file")
		return
	}

	// Check if the API is already running
	resp, err := http.Get(os.Getenv("ENDPOINT") + "/")
	if err == nil && resp.StatusCode == http.StatusOK {
		fmt.Println("API already running on " + os.Getenv("ENDPOINT") + "/")
		return
	}

	// Endpoint
	http.HandleFunc("/api/ocr", GeminiHandler)
	http.HandleFunc("/api/", APICheck)

	// Listening
	fmt.Println("Server started on " + os.Getenv("ENDPOINT") + "/ ...")
	http.ListenAndServe(":8080", nil)
}

func GeminiHandler(w http.ResponseWriter, r *http.Request) {
	context := context.Background()

	apiKey := os.Getenv("API_KEY")
	if apiKey == "" {
		http.Error(w, "API_KEY not found in env", http.StatusInternalServerError)
		return 
	}

	// 1. Read Multipart data from the request 
	err := r.ParseMultipartForm(10 << 20) // 10 MB limit
	if err != nil {
		http.Error(w, "Failed to parse form: "+err.Error(), http.StatusBadRequest)
		return
	}

	// get the file from the form data
	file, handler, err := r.FormFile("image")
	if err != nil {
		http.Error(w, "Error retrieving file: "+err.Error(), http.StatusBadRequest)
		return
	}
	defer file.Close()

	fmt.Printf("Received file: %s (%d bytes)\n", handler.Filename, handler.Size)

	// 2. Reading file to []byte
	imgBytes, err := io.ReadAll(file)
	if err != nil {
		http.Error(w, "Error reading image file: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// 3. Create gemini client
	client, err := genai.NewClient(context, option.WithAPIKey(apiKey))
	if err != nil {
		http.Error(w, "Failed to create Gemini client: "+err.Error(), http.StatusInternalServerError)
		return
	}
	defer client.Close()

	// 4. Create model
	model := client.GenerativeModel("gemini-1.5-flash")

	// 5. Create prompt and token
	prompt := "Perform OCR on this image. Extract only the code and comments exactly as seen, without any explanation or additional content. Ensure the code is cleanly formatted and properly indented."

	req := []genai.Part{
		genai.Text(prompt),
		genai.ImageData("image/png", imgBytes),
	}

	// 6. Generate content
	res, err := model.GenerateContent(context, req...)
	if err != nil {
		http.Error(w, "Failed to generate content: "+err.Error(), http.StatusInternalServerError)
		return
	}
	
	// 7. Take output from the response
	var output string
	for _, cand := range res.Candidates {
		for _, part := range cand.Content.Parts {
			if text, ok := part.(genai.Text); ok {
				output += string(text)
			}
		}
	}

	// w.Header().Set("Content-Type", "text/plain") // Uncomment this line to send the output as a response
	// w.Write([]byte(output)) // Uncomment this line to send the output as a response

	// Output with JSON
	result := map[string]string{
		"code": output,
	}
	
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(result)

}

func APICheck(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintln(w, "You good to go!")
}