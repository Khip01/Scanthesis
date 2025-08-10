<div align="center">
  <img src="https://img.shields.io/badge/Scanthesis-AI%20Code%20Extraction-blue?style=for-the-badge" alt="Scanthesis - AI Code Extraction" />
  <h1>🔍 Scanthesis App 🖥️</h1>
  <p><strong>Extract code from images and get AI-powered responses</strong></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-Desktop-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Windows-Tested-0078D6?style=flat-square&logo=windows&logoColor=white" alt="Windows" />
    <img src="https://img.shields.io/badge/Linux-Tested-FCC624?style=flat-square&logo=linux&logoColor=black" alt="Linux" />
    <img src="https://img.shields.io/badge/Gemini%201.5-Flash-8E75B2?style=flat-square&logo=google&logoColor=white" alt="Gemini 1.5 Flash" />
    <img src="https://img.shields.io/badge/API-Customizable-4CAF50?style=flat-square&logo=postman&logoColor=white" alt="Customizable API" />
  </p>
</div>

<p align="center">
  <img src="https://i.ibb.co.com/yKpD2w7/app-clean.jpg" alt="Scanthesis App Screenshots" style="max-height: 50vh; border-radius:12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
</p>

## Overview
**Scanthesis** is a simple multi-platform desktop application built with Flutter, designed primarily for extracting code from images through AI-powered services. The app provides a straightforward interface similar to chat AI applications, with each interaction consisting of a single prompt and response.

## Features
- **Code Extraction from Images**: Convert code in images to text using AI services
- **Custom API Integration**: Connect to your preferred AI backend by configuring endpoints
- **Platform Support**: 
  - Fully tested and **functional on Windows 11 and Linux** (ubuntu/debian based)
  - Built with Flutter for potential macOS compatibility _(untested)_
- **Simple Chat Interface**: Single prompt and response per chat session
- **Customizable Backend**: Use the included Golang API example (using Gemini 1.5 Flash) or configure your own AI service
- **Markdown Output**: Receive AI responses formatted in Markdown

## Technical Implementation
This application serves as a desktop interface for AI services, allowing you to:
- Configure API endpoints in the settings page
- Use the included Golang backend example (requires your API key)
- Customize the JSON response structure to work with different AI providers

## Getting Started

### Option 1: Using the Built-in Golang API

The repository includes a simple Golang API implementation that connects to Gemini 1.5 Flash:

1. Navigate to the `scanthesis_api` directory
2. Copy `.env.example` to create a new `.env` file
3. Configure your environment variables in the `.env` file:
   ```
   API_KEY="your_api_key_here"
   ENDPOINT="http://127.0.0.1:8080/api"
   ```
   > [!NOTE]
   > You can obtain an API key from [Google AI Studio](https://aistudio.google.com/apikey)
4. Run the API server:
   ```
   go run main.go
   ```
5. Launch the Scanthesis desktop application and configure the endpoint URL in the settings page to match your API server (default: `http://127.0.0.1:8080/api`)

### Option 2: Using a Custom API

If you prefer to use your own AI backend:

1. Launch the Scanthesis application and navigate to the settings page
2. Enter your custom API endpoint URL in the designated field
    <p align="left">
      <img src="https://i.ibb.co.com/m3SXzJp/api-settings-page.png" alt="google asset error" style="max-height:500px; border-radius:12px">
    </p>

3. If your API returns a different JSON structure than the default, you'll need to modify the response model:
   
   Open `scanthesis_app/lib/models/api_response.dart` and customize the `MyCustomResponse` class to match your API's response structure:
   
   ```dart
   class MyCustomResponse {
     final String response;
     // Add or modify fields according to your JSON response structure
   
     MyCustomResponse({required this.response});
   
     factory MyCustomResponse.fromJson(Map<String, dynamic> json) {
       return MyCustomResponse(response: json['response']);
     }
   
     Map<String, dynamic> toJson() => {"response": response};
   
     @override
     String toString() => response;
   }
   ```

> [!NOTE] 
> The application is configured to send requests with the structure defined in `scanthesis_app/lib/models/api_request.dart`. Customizing the request format is not fully supported in the current version.

## API Request Format

For reference, the application sends requests in the following format:

```json
{
  "files": ["path/to/file1.jpg", "path/to/file2.png"],
  "prompt": "User's text prompt"
}
```

Ensure your custom API can handle this format or modify the request model in the source code if necessary.
      