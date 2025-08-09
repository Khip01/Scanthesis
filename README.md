# Scanthesis App

## Overview
**Scanthesis** is a simple multi-platform desktop application built with Flutter, designed primarily for extracting code from images through AI-powered services. The app provides a straightforward interface similar to chat AI applications, with each interaction consisting of a single prompt and response.

## Features
- **Code Extraction from Images**: Convert code in images to text using AI services
- **Custom API Integration**: Connect to your preferred AI backend by configuring endpoints
- **Platform Support**: 
  - Fully tested and functional on Windows 11 and Linux (ubuntu/debian based)
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
The repository includes a simple Golang API implementation that connects to Gemini 1.5 Flash. To use it:
1. Configure your API key
2. Run `go run main.go`
3. Set the API endpoint in the Scanthesis app settings

Developers can also implement their own backend solutions by following the JSON structure examples provided in the repository.
