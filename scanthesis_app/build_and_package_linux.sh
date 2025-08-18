#!/bin/bash
# Script to build a Flutter Linux application and create distribution packages

#==============================================================================
# CONFIGURATION SECTION - Customize these values
#==============================================================================
# Application information - should match values in package_linux_distributions.sh
APP_NAME="scanthesis"
VERSION="1.0.0"

# Build configuration
FLUTTER_BUILD_ARGS="--release"  # Default build mode
#==============================================================================
# END OF CONFIGURATION SECTION
#==============================================================================

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --app-name)
      APP_NAME="$2"
      shift 2
      ;;
    --version)
      VERSION="$2"
      shift 2
      ;;
    --debug)
      FLUTTER_BUILD_ARGS="--debug"
      shift
      ;;
    --profile)
      FLUTTER_BUILD_ARGS="--profile"
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --app-name NAME    Application name (default: $APP_NAME)"
      echo "  --version VERSION  Application version (default: $VERSION)"
      echo "  --debug            Build in debug mode instead of release"
      echo "  --profile          Build in profile mode instead of release"
      echo "  --help             Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Detect if running on Windows
IS_WINDOWS=false
if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]]; then
    IS_WINDOWS=true
    echo "⚠️ Windows environment detected. Using 'flutter.bat' instead of 'flutter'"
    FLUTTER_CMD="flutter.bat"
else
    FLUTTER_CMD="flutter"
fi

echo "🚀 Starting Flutter build for Linux..."
$FLUTTER_CMD build linux $FLUTTER_BUILD_ARGS

# Check if build was successful
if [ $? -eq 0 ]; then
    echo "✅ Flutter build completed successfully"

    # Detect build mode from arguments
    BUILD_MODE="release"
    if [[ "$FLUTTER_BUILD_ARGS" == *"--debug"* ]]; then
        BUILD_MODE="debug"
    elif [[ "$FLUTTER_BUILD_ARGS" == *"--profile"* ]]; then
        BUILD_MODE="profile"
    fi

    # Set the bundle directory based on build mode
    BUNDLE_DIR="build/linux/x64/$BUILD_MODE/bundle"

    # Add Docker warning if on Windows
    if [[ "$IS_WINDOWS" == true ]]; then
        echo ""
        echo "⚠️ IMPORTANT: Building Linux packages on Windows requires Docker Desktop."
        echo "   Please ensure Docker Desktop is installed and running before continuing."
        echo "   Press CTRL+C to cancel or any key to continue..."
        read -n 1
    fi

    # Run packaging script with detected build directory
    ./package_linux_distributions.sh --app-name "$APP_NAME" --version "$VERSION" --bundle-dir "$BUNDLE_DIR"
else
    echo "❌ Flutter build failed. Please fix the errors before creating packages."
    exit 1
fi