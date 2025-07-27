class Strings {
  static const String defaultPrompt = "Perform OCR on this image. Extract only the code and comments exactly as seen, without any explanation or additional content. Ensure the code is cleanly formatted and properly indented.";
  static const String aboutApp = """
# 🚀 Scanthesis App

**Scanthesis App** is a multi-platform desktop application (Windows, Linux, and macOS) that helps developers extract code from images and interact with AI to get insightful responses - all in a seamless, customizable way.

---

### 🧠 What It Does

- 🖼️ **OCR for Code Snippets**  
  Upload or capture images containing source code. Scanthesis extracts the text using OCR optimized for programming syntax.

- ✍️ **Custom AI Prompts**  
  Define your own prompts to shape how the AI interprets your scanned code - perfect for explanations, debugging, refactoring suggestions, or documentation.

- 🧾 **AI Responses in Markdown**  
  AI responses are rendered with Markdown formatting, making them easy to read, copy, and share.

- 🌐 **Pluggable API Endpoint**  
  Use your own AI API! Point Scanthesis to OpenAI, a local model, or your own hosted endpoint.

- 💻 **Cross-Platform Support**  
  Built with Flutter - works natively on Windows, Linux, and macOS.

---

### 💡 Use Cases

- Instantly extract and analyze code from tutorials, screenshots, or whiteboard photos
- Use custom prompts to get explanations tailored to your style or language
- Build your own dev workflow around a flexible and privacy-respecting AI interface

---

### 🔐 Privacy-Friendly

You control the API endpoint - no data is sent anywhere unless you configure it. Ideal for local, offline, or private setups.

---

### 🛠️ Built With

- Flutter (multi-platform desktop)
- Dio (networking)
- Gemini 1.5 flash
- Markdown renderer
- Bloc + Provider (state management)

---

### 🧩 One-Line Description (5 Words)

**Extract, Prompt, Render - with AI**
""";

  static String httpStatusDescription(int? statusCode) {
    switch (statusCode) {
      case 200:
        return "OK";
      case 201:
        return "Created";
      case 204:
        return "No Content";
      case 400:
        return "Bad Request";
      case 401:
        return "Unauthorized";
      case 403:
        return "Forbidden";
      case 404:
        return "Not Found";
      case 405:
        return "Method Not Allowed";
      case 408:
        return "Request Timeout";
      case 500:
        return "Internal Server Error";
      case 502:
        return "Bad Gateway";
      case 503:
        return "Service Unavailable";
      default:
        return "Unknown";
    }
  }
}