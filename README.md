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
  <img src="https://i.ibb.co.com/yKpD2w7/app-clean.jpg" alt="Scanthesis App Screenshots" style="width: 750px; border-radius:12px; box-shadow: 0 4px 8px rgba(0,0,0,0.2);">
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

## Development Requirements

### Environment Setup
- **Flutter**: Version 3.32.4 or above
- **Supported Development Platforms**:
  - **Windows**: Windows 11 Home 23H2 with Android Studio Hedgehog | 2023.1.1 Patch 2
  - **Linux**: Ubuntu/Debian based systems (Tested on KDE Plasma 6 Wayland) with Android Studio Meerkat Feature Drop | 2024.3.2 Patch 1
- **Additional Tools**:
  - Postman (for API testing)

### Prerequisites
Before running the application, ensure your Flutter environment is properly configured:

```bash
# Verify Flutter installation and dependencies
flutter doctor
```

Make sure all platform-specific requirements are met:
- For Windows: Windows desktop development is enabled
- For Linux: Linux desktop development is enabled

```bash
# Enable desktop development
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

#### Linux System Dependencies
If developing on Linux, you'll need to install additional system packages for certain Flutter plugins:

```bash
# For tray_manager plugin (system tray functionality)
# For Ubuntu/Debian-based distributions
sudo apt-get install libayatana-appindicator3-dev
# OR alternative package (for older distributions)
sudo apt-get install appindicator3-0.1 libappindicator3-dev

# For hotkey_manager plugin (keyboard shortcuts)
sudo apt-get install keybinder-3.0
```
These packages are required for the application's system tray and global hotkey functionality to work correctly.

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
      <img src="https://i.ibb.co.com/m3SXzJp/api-settings-page.png" alt="Scanthesis settings - API Endpoint" style="width:600px; border-radius:12px">
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
      
## Linux Distribution Packages

Scanthesis provides a convenient way to build and package the application for various Linux distributions. The included scripts automatically create packages for Debian-based systems (.deb), Fedora/RHEL (.rpm), Arch Linux (.tar.zst), and a universal AppImage.

### Building Linux Packages

To build the application for Linux and create distribution packages:

1. Navigate to the `scanthesis_app` directory
2. Run the build and package script:
   ```bash
   cd scanthesis_app
   chmod +x build_and_package_linux.sh
   ./build_and_package_linux.sh
   ```
3. The packages will be created in the linux_packages directory:
- `scanthesis_1.0.0_amd64.deb` - For Debian, Ubuntu, Linux Mint, etc.
- `rpm_output/scanthesis-1.0.0-1.fc42.x86_64.rpm` - For Fedora, RHEL, CentOS, etc.
- `scanthesis-1.0.0-1-x86_64.pkg.tar.zst` - For Arch Linux, Manjaro, etc.
- `scanthesis_1.0.0-x86_64.AppImage` - Universal Linux package

### Installation from Packages
#### Debian/Ubuntu and derivatives:
```bash
sudo dpkg -i linux_packages/scanthesis_1.0.0_amd64.deb
```
#### Fedora/RHEL and derivatives:
```bash
sudo rpm -i linux_packages/rpm_output/scanthesis-1.0.0-1.fc42.x86_64.rpm
```
#### Arch Linux and derivatives:
```bash
sudo pacman -U linux_packages/scanthesis-1.0.0-1-x86_64.pkg.tar.zst
```
#### Any Linux distribution (AppImage):
```bash
chmod +x linux_packages/scanthesis_1.0.0-x86_64.AppImage
./linux_packages/scanthesis_1.0.0-x86_64.AppImage
```

### Advanced Options
The packaging script supports several options:

```bash
./build_and_package_linux.sh --help
```
Common options include:
- `--app-name NAME`: Set the application name (default: scanthesis)
- `--version VERSION`: Set the application version (default: 1.0.0)
- `--icon PATH`: Path to the application icon (default: assets/app_icon/scanthesis-app-icon-600x600.png)
- `--force-docker`: Use Docker for all package formats regardless of native tools
- `--no-docker`: Don't use Docker even if native tools are missing

## Windows Installation

Scanthesis also provides a way to create a Windows installer using Inno Setup.

### Building Windows Installer

To create a Windows installer:

1. Make sure you have [Inno Setup](https://jrsoftware.org/isinfo.php) installed
2. Build the Flutter application for Windows:
   ```bash
   cd scanthesis_app
   flutter build windows --release
   ```
3. Run the Inno Setup script file (located at `windows/installer/scanthesis_build_installer.iss`) using the Inno Setup Compiler
4. The installer will be created in the `windows/installer` folder named `scanthesis_setup_v{version}.exe` (where `{version}` is the version defined in the .iss file)

### Installer Configuration

If you want to customize the installer, you can modify the `windows/installer/scanthesis_build_installer.iss` file. This file contains the configuration for creating the Windows installer, including application information, files to include, and installation options.