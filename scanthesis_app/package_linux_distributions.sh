#!/bin/bash
# Script for creating Linux distribution packages from a Flutter application build
# Supports cross-platform execution (Linux distributions and Windows via WSL/Docker)

#==============================================================================
# CONFIGURATION SECTION - Customize these values
#==============================================================================
# Application information
APP_NAME="scanthesis"
VERSION="1.0.0"
APP_DESCRIPTION="Scanthesis - AI-powered code extractor"
DEFAULT_BUNDLE_DIR="build/linux/x64/release/bundle"
DEFAULT_ICON_PATH="assets/app_icon/scanthesis-app-icon-600x600.png"

# Developer/Maintainer information
MAINTAINER_NAME="Khip01"
MAINTAINER_EMAIL="your.email@example.com"

# Repository information
REPO_USERNAME="Khip01"
REPO_NAME="Scanthesis"
REPO_URL="https://github.com/${REPO_USERNAME}/${REPO_NAME}"

# Application category (https://specifications.freedesktop.org/menu-spec/latest/apa.html)
APP_CATEGORY="Utility;"

# License (for package metadata)
APP_LICENSE="MIT"

# Dependencies
DEB_DEPENDENCIES="libgtk-3-0, libblkid1, liblzma5"
RPM_DEPENDENCIES="gtk3"
ARCH_DEPENDENCIES="gtk3"

# Build configuration
OUTPUT_DIR="linux_packages"  # Directory where packages will be saved
#==============================================================================
# END OF CONFIGURATION SECTION
#==============================================================================

set -e  # Exit on error

# Platform detection
IS_WINDOWS=false
IS_DEBIAN=false
IS_FEDORA=false
IS_ARCH=false
NEEDS_DOCKER_FOR_DEB=false
NEEDS_DOCKER_FOR_RPM=false
NEEDS_DOCKER_FOR_ARCH=false

# Check if running on Windows (via Git Bash or WSL)
if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]]; then
    IS_WINDOWS=true
    echo "📊 Detected Windows environment"
    NEEDS_DOCKER_FOR_DEB=true
    NEEDS_DOCKER_FOR_RPM=true
    NEEDS_DOCKER_FOR_ARCH=true
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    if [[ "$ID" == "debian" ]] || [[ "$ID_LIKE" == *"debian"* ]]; then
        IS_DEBIAN=true
        NEEDS_DOCKER_FOR_RPM=true
        NEEDS_DOCKER_FOR_ARCH=true
        echo "📊 Detected Debian-based distribution (${PRETTY_NAME})"
    elif [[ "$ID" == "fedora" ]] || [[ "$ID_LIKE" == *"fedora"* ]]; then
        IS_FEDORA=true
        NEEDS_DOCKER_FOR_DEB=true
        NEEDS_DOCKER_FOR_ARCH=true
        echo "📊 Detected Fedora-based distribution (${PRETTY_NAME})"
    elif [[ "$ID" == "arch" ]] || [[ "$ID_LIKE" == *"arch"* ]]; then
        IS_ARCH=true
        NEEDS_DOCKER_FOR_DEB=true
        NEEDS_DOCKER_FOR_RPM=true
        echo "📊 Detected Arch-based distribution (${PRETTY_NAME})"
    else
        echo "📊 Detected Linux distribution: ${PRETTY_NAME}"
        echo "⚠️ This distribution is not specifically recognized. Will attempt to detect tools."
        # Check for native packaging tools
        if command -v dpkg-deb &> /dev/null; then
            IS_DEBIAN=true
        elif command -v rpmbuild &> /dev/null; then
            IS_FEDORA=true
        elif command -v makepkg &> /dev/null; then
            IS_ARCH=true
        fi
        NEEDS_DOCKER_FOR_DEB=! $IS_DEBIAN
        NEEDS_DOCKER_FOR_RPM=! $IS_FEDORA
        NEEDS_DOCKER_FOR_ARCH=! $IS_ARCH
    fi
else
    echo "⚠️ Unable to determine operating system. Will attempt to detect tools."
    # Check for native packaging tools
    if command -v dpkg-deb &> /dev/null; then
        IS_DEBIAN=true
    elif command -v rpmbuild &> /dev/null; then
        IS_FEDORA=true
    elif command -v makepkg &> /dev/null; then
        IS_ARCH=true
    fi
    NEEDS_DOCKER_FOR_DEB=! $IS_DEBIAN
    NEEDS_DOCKER_FOR_RPM=! $IS_FEDORA
    NEEDS_DOCKER_FOR_ARCH=! $IS_ARCH
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Allow overriding defaults via environment variables
BUNDLE_DIR="${BUNDLE_DIR:-$DEFAULT_BUNDLE_DIR}"
APP_ICON="${APP_ICON:-$DEFAULT_ICON_PATH}"

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
    --bundle-dir)
      BUNDLE_DIR="$2"
      shift 2
      ;;
    --icon)
      APP_ICON="$2"
      shift 2
      ;;
    --force-docker)
      NEEDS_DOCKER_FOR_DEB=true
      NEEDS_DOCKER_FOR_RPM=true
      NEEDS_DOCKER_FOR_ARCH=true
      shift
      ;;
    --no-docker)
      NEEDS_DOCKER_FOR_DEB=false
      NEEDS_DOCKER_FOR_RPM=false
      NEEDS_DOCKER_FOR_ARCH=false
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --app-name NAME     Application name (default: $APP_NAME)"
      echo "  --version VERSION   Application version (default: $VERSION)"
      echo "  --bundle-dir DIR    Path to Flutter build bundle directory (default: $BUNDLE_DIR)"
      echo "  --icon PATH         Path to application icon (default: $APP_ICON)"
      echo "  --force-docker      Use Docker for all package formats regardless of native tools"
      echo "  --no-docker         Don't use Docker even if native tools are missing (may fail)"
      echo "  --help              Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information"
      exit 1
      ;;
  esac
done

# Check Docker availability if needed
if [[ "$NEEDS_DOCKER_FOR_DEB" == true ]] || [[ "$NEEDS_DOCKER_FOR_RPM" == true ]] || [[ "$NEEDS_DOCKER_FOR_ARCH" == true ]]; then
    if ! command -v docker &> /dev/null; then
        echo "⚠️ Docker is required for some package formats but not found. Install Docker to build all package types."
        echo "   Docker is needed for:"
        [[ "$NEEDS_DOCKER_FOR_DEB" == true ]] && echo "   - Debian (.deb) packages"
        [[ "$NEEDS_DOCKER_FOR_RPM" == true ]] && echo "   - RPM packages"
        [[ "$NEEDS_DOCKER_FOR_ARCH" == true ]] && echo "   - Arch Linux packages"
        echo ""
        echo "   The script will skip formats requiring Docker."
        echo "   To install Docker:"
        echo "   - Ubuntu/Debian: sudo apt install docker.io"
        echo "   - Fedora: sudo dnf install docker"
        echo "   - Arch: sudo pacman -S docker"
        echo "   - Windows: Install Docker Desktop for Windows"
    fi
fi

# Ensure the icon path is resolved correctly
if [[ ! -f "$APP_ICON" ]]; then
  # Try to find the icon in the project
  for search_path in "assets" "linux/assets" "linux/assets/icons" "assets/app_icon"; do
    if [[ -f "$search_path/$(basename $APP_ICON)" ]]; then
      APP_ICON="$search_path/$(basename $APP_ICON)"
      echo "✓ Found application icon at: $APP_ICON"
      break
    fi
  done

  if [[ ! -f "$APP_ICON" ]]; then
    echo "⚠️ Warning: Application icon not found at $APP_ICON"
    echo "   Icon paths in package files may need manual adjustment"
  fi
fi

# Get the actual Flutter assets path based on the bundle structure
ASSETS_PATH="data/flutter_assets"

echo "🔍 Verifying Flutter build..."
if [ ! -d "$BUNDLE_DIR" ]; then
    echo "❌ Build directory not found: $BUNDLE_DIR"
    echo "   Run 'flutter build linux --release' first or specify correct path with --bundle-dir"
    exit 1
fi

echo "📋 Configuration:"
echo "   • Application name: $APP_NAME"
echo "   • Version: $VERSION"
echo "   • Bundle directory: $BUNDLE_DIR"
echo "   • Icon path: $APP_ICON"
echo "   • Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>"
echo ""
echo "📋 Build environment:"
[[ "$IS_WINDOWS" == true ]] && echo "   • OS: Windows (via WSL/Git Bash)"
[[ "$IS_DEBIAN" == true ]] && echo "   • OS: Debian-based Linux"
[[ "$IS_FEDORA" == true ]] && echo "   • OS: Fedora-based Linux"
[[ "$IS_ARCH" == true ]] && echo "   • OS: Arch-based Linux"
[[ "$NEEDS_DOCKER_FOR_DEB" == true ]] && echo "   • .deb: Using Docker"
[[ "$NEEDS_DOCKER_FOR_DEB" == false ]] && echo "   • .deb: Using native tools"
[[ "$NEEDS_DOCKER_FOR_RPM" == true ]] && echo "   • .rpm: Using Docker"
[[ "$NEEDS_DOCKER_FOR_RPM" == false ]] && echo "   • .rpm: Using native tools"
[[ "$NEEDS_DOCKER_FOR_ARCH" == true ]] && echo "   • .tar.zst: Using Docker"
[[ "$NEEDS_DOCKER_FOR_ARCH" == false ]] && echo "   • .tar.zst: Using native tools"

# Copy icon to bundle if not already there
mkdir -p "$BUNDLE_DIR/$ASSETS_PATH/assets"
if [[ -f "$APP_ICON" ]]; then
  cp -f "$APP_ICON" "$BUNDLE_DIR/$ASSETS_PATH/assets/app_icon.png"
  BUNDLE_ICON_PATH="$ASSETS_PATH/assets/app_icon.png"
else
  # Try to find an existing icon in the bundle
  BUNDLE_ICON_PATH=$(find "$BUNDLE_DIR/$ASSETS_PATH" -name "*.png" | head -n 1)
  BUNDLE_ICON_PATH=${BUNDLE_ICON_PATH#"$BUNDLE_DIR/"}

  if [[ -z "$BUNDLE_ICON_PATH" ]]; then
    echo "⚠️ No icon found. Packages will be created without icon references."
    BUNDLE_ICON_PATH=""
  else
    echo "✓ Using existing icon in bundle: $BUNDLE_ICON_PATH"
  fi
fi

# Function to build .deb package natively
build_deb_native() {
    echo "📦 Creating Debian package (.deb) using native tools..."
    mkdir -p deb_package/DEBIAN
    mkdir -p deb_package/usr/bin/$APP_NAME
    mkdir -p deb_package/usr/share/applications
    mkdir -p deb_package/usr/share/icons/hicolor/256x256/apps

    # Create control file
    cat > deb_package/DEBIAN/control << EOF
Package: $APP_NAME
Version: $VERSION
Section: x11
Priority: optional
Architecture: amd64
Depends: $DEB_DEPENDENCIES
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Description: $APP_DESCRIPTION
EOF

    # Copy files
    cp -r $BUNDLE_DIR/* deb_package/usr/bin/$APP_NAME/

    # Copy icon to standard location if available
    if [[ -f "$APP_ICON" ]]; then
        cp -f "$APP_ICON" "deb_package/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
    fi

    # Create desktop entry
    cat > deb_package/usr/share/applications/$APP_NAME.desktop << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=/usr/bin/$APP_NAME/$APP_NAME
Type=Application
Categories=$APP_CATEGORY
EOF

    # Add icon to desktop entry
    if [[ -f "$APP_ICON" ]]; then
        echo "Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> deb_package/usr/share/applications/$APP_NAME.desktop
    elif [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
        echo "Icon=/usr/bin/$APP_NAME/$BUNDLE_ICON_PATH" >> deb_package/usr/share/applications/$APP_NAME.desktop
    fi

    # Build .deb
    dpkg-deb --build deb_package "${OUTPUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb"
    echo "✅ .deb package created: ${OUTPUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb"
}

# Function to build .deb package with Docker
build_deb_docker() {
    echo "📦 Creating Debian package (.deb) using Docker..."

    # Create temporary directory for Docker build
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/build"

    # Copy necessary files to temp directory
    cp -r "$BUNDLE_DIR" "$TEMP_DIR/build/bundle"
    [[ -f "$APP_ICON" ]] && cp "$APP_ICON" "$TEMP_DIR/build/icon.png"

    # Create build script
    cat > "$TEMP_DIR/build_deb.sh" << EOF
#!/bin/bash
set -e
mkdir -p /build/deb_package/DEBIAN
mkdir -p /build/deb_package/usr/bin/$APP_NAME
mkdir -p /build/deb_package/usr/share/applications
mkdir -p /build/deb_package/usr/share/icons/hicolor/256x256/apps

# Create control file
cat > /build/deb_package/DEBIAN/control << EOC
Package: $APP_NAME
Version: $VERSION
Section: x11
Priority: optional
Architecture: amd64
Depends: $DEB_DEPENDENCIES
Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
Description: $APP_DESCRIPTION
EOC

# Copy files
cp -r /build/bundle/* /build/deb_package/usr/bin/$APP_NAME/

# Copy icon to standard location if available
if [[ -f "/build/icon.png" ]]; then
    cp -f "/build/icon.png" "/build/deb_package/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
fi

# Create desktop entry
cat > /build/deb_package/usr/share/applications/$APP_NAME.desktop << EOD
[Desktop Entry]
Name=$APP_NAME
Exec=/usr/bin/$APP_NAME/$APP_NAME
Type=Application
Categories=$APP_CATEGORY
EOD

# Add icon to desktop entry
if [[ -f "/build/icon.png" ]]; then
    echo "Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> /build/deb_package/usr/share/applications/$APP_NAME.desktop
elif [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
    echo "Icon=/usr/bin/$APP_NAME/$BUNDLE_ICON_PATH" >> /build/deb_package/usr/share/applications/$APP_NAME.desktop
fi

# Build .deb
dpkg-deb --build /build/deb_package /output/${APP_NAME}_${VERSION}_amd64.deb
EOF

    chmod +x "$TEMP_DIR/build_deb.sh"

    # Run Docker container
    docker run --rm \
        -v "$TEMP_DIR:/build" \
        -v "$(pwd)/$OUTPUT_DIR:/output" \
        debian:bullseye \
        bash -c "apt-get update && apt-get install -y dpkg-dev && /build/build_deb.sh"

    # Clean up
    rm -rf "$TEMP_DIR"

    echo "✅ .deb package created: ${OUTPUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb"
}

# Function to build AppImage (always native since it's just a wrapper)
build_appimage() {
    echo "📦 Creating AppImage..."
    mkdir -p AppDir/usr/{bin,lib,share/applications}

    # Copy application
    cp -r $BUNDLE_DIR/* AppDir/usr/bin/

    # Copy icon to AppDir root - THIS IS IMPORTANT FOR APPIMAGETOOL
    if [[ -f "$APP_ICON" ]]; then
        # Copy icon to both root directory and standard location
        cp -f "$APP_ICON" "AppDir/$APP_NAME.png"

        # Also ensure we have the icon in standard locations
        mkdir -p AppDir/usr/share/icons/hicolor/256x256/apps/
        cp -f "$APP_ICON" "AppDir/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"

        # Copy icon for AppImage menu
        mkdir -p AppDir/usr/share/icons/hicolor/128x128/apps/
        cp -f "$APP_ICON" "AppDir/usr/share/icons/hicolor/128x128/apps/$APP_NAME.png"
    fi

    # Create desktop entry
    cat > AppDir/usr/share/applications/$APP_NAME.desktop << EOF
[Desktop Entry]
Name=$APP_NAME
Exec=$APP_NAME
Icon=$APP_NAME
Type=Application
Categories=$APP_CATEGORY
EOF

    # Symlinks
    ln -sf usr/share/applications/$APP_NAME.desktop AppDir/$APP_NAME.desktop
    ln -sf usr/bin/$APP_NAME AppDir/AppRun

    # Download appimagetool if not available
    if [ ! -f "appimagetool" ]; then
        wget -O appimagetool "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
        chmod +x appimagetool
    fi

    # Generate AppImage
    ARCH=x86_64 ./appimagetool AppDir "${OUTPUT_DIR}/${APP_NAME}_${VERSION}-x86_64.AppImage"
    echo "✅ AppImage created: ${OUTPUT_DIR}/${APP_NAME}_${VERSION}-x86_64.AppImage"
}

# Function to build RPM package natively
build_rpm_native() {
    echo "📦 Creating RPM package using native tools..."

    # Set up RPM build environment
    if [[ ! -d "$HOME/rpmbuild" ]]; then
        mkdir -p "$HOME/rpmbuild"/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
    fi

    # Copy sources to rpmbuild directory
    mkdir -p "$HOME/rpmbuild/SOURCES"
    cp -r "$BUNDLE_DIR"/* "$HOME/rpmbuild/SOURCES/"

    # Create spec file
    cat > "$HOME/rpmbuild/SPECS/$APP_NAME.spec" << EOF
Name:           $APP_NAME
Version:        $VERSION
Release:        1%{?dist}
Summary:        $APP_DESCRIPTION

License:        $APP_LICENSE
BuildArch:      x86_64

Requires:       $RPM_DEPENDENCIES

%description
$APP_DESCRIPTION

%install
mkdir -p %{buildroot}/usr/bin/$APP_NAME
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
cp -r %{_sourcedir}/* %{buildroot}/usr/bin/$APP_NAME/
EOF

    # Copy icon if available
    if [[ -f "$APP_ICON" ]]; then
        cp -f "$APP_ICON" "$HOME/rpmbuild/SOURCES/app_icon.png"
        echo "install -D -m 644 %{_sourcedir}/app_icon.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec"
    fi

    # Continue with spec file
    cat >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec" << EOF
cat > %{buildroot}/usr/share/applications/$APP_NAME.desktop << EOS
[Desktop Entry]
Name=$APP_NAME
Exec=/usr/bin/$APP_NAME/$APP_NAME
Type=Application
Categories=$APP_CATEGORY
EOF

    # Add icon to spec file if available
    if [[ -f "$APP_ICON" ]]; then
        echo "Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec"
    elif [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
        echo "Icon=/usr/bin/$APP_NAME/$BUNDLE_ICON_PATH" >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec"
    fi

    # Complete the spec file
    cat >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec" << EOF
EOS

%files
/usr/bin/$APP_NAME
/usr/share/applications/$APP_NAME.desktop
EOF

    # Add icon to files if available
    if [[ -f "$APP_ICON" ]]; then
        echo "/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec"
    fi

    # Add changelog
    cat >> "$HOME/rpmbuild/SPECS/$APP_NAME.spec" << EOF

%changelog
* $(date "+%a %b %d %Y") $MAINTAINER_NAME <$MAINTAINER_EMAIL> - $VERSION-1
- Initial package
EOF

    # Build RPM
    rpmbuild -bb "$HOME/rpmbuild/SPECS/$APP_NAME.spec"

    # Copy RPM to output directory
    mkdir -p "${OUTPUT_DIR}/rpm_output"
    find "$HOME/rpmbuild/RPMS" -name "*.rpm" -exec cp {} "${OUTPUT_DIR}/rpm_output/" \;

    echo "✅ RPM package created in ${OUTPUT_DIR}/rpm_output/ folder"
}

# Function to build RPM package with Docker
build_rpm_docker() {
    echo "📦 Creating RPM package using Docker..."

    # Create output directory if it doesn't exist
    mkdir -p "${OUTPUT_DIR}/rpm_output"

    # Use a local temp directory inside the project folder
    LOCAL_TEMP_DIR=".docker_rpm_temp"
    mkdir -p "$LOCAL_TEMP_DIR"

    # Create spec file
    cat > rpm.spec << EOF
Name:           $APP_NAME
Version:        $VERSION
Release:        1%{?dist}
Summary:        $APP_DESCRIPTION

License:        $APP_LICENSE
BuildArch:      x86_64

Requires:       $RPM_DEPENDENCIES

# Don't run debuginfo packages - Flutter has stripped binaries
%global debug_package %{nil}

%description
$APP_DESCRIPTION

%install
mkdir -p %{buildroot}/usr/bin/$APP_NAME
mkdir -p %{buildroot}/usr/share/applications
mkdir -p %{buildroot}/usr/share/icons/hicolor/256x256/apps
cp -r %{_sourcedir}/* %{buildroot}/usr/bin/$APP_NAME/

# Create desktop entry
cat > %{buildroot}/usr/share/applications/$APP_NAME.desktop << EOS
[Desktop Entry]
Name=$APP_NAME
Exec=/usr/bin/$APP_NAME/$APP_NAME
Type=Application
Categories=$APP_CATEGORY
EOS

# Copy icon to standard location if available
if [ -f "%{_sourcedir}/$ASSETS_PATH/assets/app_icon.png" ]; then
    install -D -m 644 %{_sourcedir}/$ASSETS_PATH/assets/app_icon.png %{buildroot}/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png
    echo "Icon=/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png" >> %{buildroot}/usr/share/applications/$APP_NAME.desktop
else
    # Fall back to bundled icon if available
    echo "Icon=/usr/bin/$APP_NAME/$ASSETS_PATH/assets/app_icon.png" >> %{buildroot}/usr/share/applications/$APP_NAME.desktop
fi

%files
%dir /usr/bin/$APP_NAME
/usr/bin/$APP_NAME/*
/usr/share/applications/$APP_NAME.desktop
/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png

%changelog
* $(date "+%a %b %d %Y") $MAINTAINER_NAME <$MAINTAINER_EMAIL> - $VERSION-1
- Initial package
EOF

    # Create Dockerfile for RPM building
    cat > Dockerfile.rpm << EOF
FROM fedora:latest
RUN dnf -y install rpm-build rpmdevtools chrpath patchelf
WORKDIR /app
RUN rpmdev-setuptree
COPY rpm.spec /root/rpmbuild/SPECS/
COPY $BUNDLE_DIR/ /root/rpmbuild/SOURCES/

# Fix invalid RPATHs in shared libraries
RUN find /root/rpmbuild/SOURCES/lib/ -name "*.so" -type f -exec patchelf --remove-rpath {} \; || true

# Build RPM with RPATH checks disabled
RUN QA_RPATHS=0x0002 rpmbuild -bb /root/rpmbuild/SPECS/rpm.spec

# Copy RPMs to a specific location for easier extraction
RUN mkdir -p /rpm_output && cp /root/rpmbuild/RPMS/x86_64/*.rpm /rpm_output/

# Check if build succeeded
RUN ls -l /rpm_output/ || (echo "RPM build failed" && exit 1)
EOF

    # Build with Docker
    docker build -t rpm-builder -f Dockerfile.rpm .

    # Extract RPMs from the container
    echo "Extracting RPM packages from container..."
    docker create --name rpm-extract rpm-builder
    docker cp rpm-extract:/rpm_output/. "${OUTPUT_DIR}/rpm_output/"
    docker rm rpm-extract

    # Check if RPMs were extracted
    if ls "${OUTPUT_DIR}/rpm_output/"*.rpm &> /dev/null; then
        echo "✅ RPM package created in ${OUTPUT_DIR}/rpm_output/ folder"
    else
        echo "❌ RPM package creation failed - no packages found"
        return 1
    fi

    # Clean up
    rm -f rpm.spec Dockerfile.rpm
    rm -rf "$LOCAL_TEMP_DIR"
}

# Function to build Arch Linux package with Docker
build_arch_docker() {
    echo "📦 Creating package for Arch Linux using Docker..."

    # Create output directory if it doesn't exist
    mkdir -p "${OUTPUT_DIR}"

    # Create Dockerfile for Arch Linux building
    cat > Dockerfile.arch << EOF
FROM archlinux:latest
# Update system and install dependencies
RUN pacman -Syu --noconfirm && pacman -S --noconfirm base-devel sudo

# Set up build environment
WORKDIR /build
RUN mkdir -p /build/pkg

# Create PKGBUILD file
RUN echo '# Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>' > /build/pkg/PKGBUILD && \\
    echo 'pkgname=$APP_NAME' >> /build/pkg/PKGBUILD && \\
    echo 'pkgver=$VERSION' >> /build/pkg/PKGBUILD && \\
    echo 'pkgrel=1' >> /build/pkg/PKGBUILD && \\
    echo 'pkgdesc="$APP_DESCRIPTION"' >> /build/pkg/PKGBUILD && \\
    echo 'arch=('"'"'x86_64'"'"')' >> /build/pkg/PKGBUILD && \\
    echo 'url="$REPO_URL"' >> /build/pkg/PKGBUILD && \\
    echo 'license=('"'"'$APP_LICENSE'"'"')' >> /build/pkg/PKGBUILD && \\
    echo 'depends=($ARCH_DEPENDENCIES)' >> /build/pkg/PKGBUILD && \\
    echo 'options=(!strip)' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo 'package() {' >> /build/pkg/PKGBUILD && \\
    echo '  # Create installation directories' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/bin"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/opt/\$pkgname"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/share/applications"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/share/icons/hicolor/256x256/apps"' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Copy Flutter application files' >> /build/pkg/PKGBUILD && \\
    echo '  cp -r /app/* "\$pkgdir/opt/\$pkgname/"' >> /build/pkg/PKGBUILD

# Add icon handling if available
EOF

    # Conditionally add icon handling
    if [[ -f "$APP_ICON" ]]; then
        cat >> Dockerfile.arch << EOF
COPY "$APP_ICON" /build/icon.png
RUN echo '  cp "/build/icon.png" "\$pkgdir/usr/share/icons/hicolor/256x256/apps/\$pkgname.png"' >> /build/pkg/PKGBUILD
EOF
    fi

    # Continue PKGBUILD content
    cat >> Dockerfile.arch << EOF
RUN echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Create executable symlink' >> /build/pkg/PKGBUILD && \\
    echo '  ln -s "/opt/\$pkgname/$APP_NAME" "\$pkgdir/usr/bin/\$pkgname"' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Create desktop entry' >> /build/pkg/PKGBUILD && \\
    echo '  cat > "\$pkgdir/usr/share/applications/\$pkgname.desktop" << EOL' >> /build/pkg/PKGBUILD && \\
    echo '[Desktop Entry]' >> /build/pkg/PKGBUILD && \\
    echo 'Name=$APP_NAME' >> /build/pkg/PKGBUILD && \\
    echo 'Exec=\$pkgname' >> /build/pkg/PKGBUILD && \\
    echo 'Type=Application' >> /build/pkg/PKGBUILD && \\
    echo 'Categories=$APP_CATEGORY' >> /build/pkg/PKGBUILD
EOF

    # Conditionally add icon to desktop entry
    if [[ -f "$APP_ICON" ]]; then
        cat >> Dockerfile.arch << EOF
RUN echo 'Icon=/usr/share/icons/hicolor/256x256/apps/\$pkgname.png' >> /build/pkg/PKGBUILD && \\
    echo 'EOL' >> /build/pkg/PKGBUILD
EOF
    elif [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
        cat >> Dockerfile.arch << EOF
RUN echo 'EOL' >> /build/pkg/PKGBUILD && \\
    echo '  echo "Icon=/opt/\$pkgname/$BUNDLE_ICON_PATH" >> "\$pkgdir/usr/share/applications/\$pkgname.desktop"' >> /build/pkg/PKGBUILD
EOF
    else
        cat >> Dockerfile.arch << EOF
RUN echo 'EOL' >> /build/pkg/PKGBUILD
EOF
    fi

    # Complete the Dockerfile
    cat >> Dockerfile.arch << EOF
RUN echo '}' >> /build/pkg/PKGBUILD

# Copy Flutter bundle
COPY $BUNDLE_DIR/ /app/

# Set up build environment and run makepkg
RUN mkdir -p /arch_output && \\
    useradd -m builder && \\
    chown -R builder:builder /build && \\
    chown -R builder:builder /arch_output && \\
    cd /build/pkg && \\
    sudo -u builder bash -c "makepkg -f" && \\
    cp *.pkg.tar.zst /arch_output/

# Verify the package was created
RUN ls -l /arch_output/ || (echo "Arch package build failed" && exit 1)
EOF

    # Build with Docker
    docker build -t arch-builder -f Dockerfile.arch .

    # Extract package from the container
    echo "Extracting Arch Linux package from container..."
    docker create --name arch-extract arch-builder
    docker cp arch-extract:/arch_output/. "${OUTPUT_DIR}/"
    docker rm arch-extract

    # Check if package was extracted
    if ls "${OUTPUT_DIR}"/*.pkg.tar.zst &> /dev/null; then
        echo "✅ Arch Linux package created in ${OUTPUT_DIR}/ directory"
    else
        echo "❌ Arch Linux package creation failed - no package found"
        return 1
    fi

    # Clean up
    rm -f Dockerfile.arch
}

# Function to build Arch Linux package with Docker
build_arch_docker() {
    echo "📦 Creating package for Arch Linux using Docker..."

    # Create output directory if it doesn't exist
    mkdir -p "${OUTPUT_DIR}"

    # Create Dockerfile for Arch Linux building
    cat > Dockerfile.arch << EOF
FROM archlinux:latest

# Update system and install dependencies
RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel sudo gtk3

# Set up build environment
WORKDIR /build
RUN mkdir -p /build/pkg

# Create PKGBUILD file
RUN echo '# Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>' > /build/pkg/PKGBUILD && \\
    echo 'pkgname=$APP_NAME' >> /build/pkg/PKGBUILD && \\
    echo 'pkgver=$VERSION' >> /build/pkg/PKGBUILD && \\
    echo 'pkgrel=1' >> /build/pkg/PKGBUILD && \\
    echo 'pkgdesc="$APP_DESCRIPTION"' >> /build/pkg/PKGBUILD && \\
    echo 'arch=('"'"'x86_64'"'"')' >> /build/pkg/PKGBUILD && \\
    echo 'url="$REPO_URL"' >> /build/pkg/PKGBUILD && \\
    echo 'license=('"'"'$APP_LICENSE'"'"')' >> /build/pkg/PKGBUILD && \\
    echo 'depends=($ARCH_DEPENDENCIES)' >> /build/pkg/PKGBUILD && \\
    echo 'options=(!strip)' >> /build/pkg/PKGBUILD && \\
    echo 'makedepends=()' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo 'build() {' >> /build/pkg/PKGBUILD && \\
    echo '  echo "No build step needed - using prebuilt Flutter bundle"' >> /build/pkg/PKGBUILD && \\
    echo '}' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo 'package() {' >> /build/pkg/PKGBUILD && \\
    echo '  # Create installation directories' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/bin"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/opt/\$pkgname"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/share/applications"' >> /build/pkg/PKGBUILD && \\
    echo '  install -d "\$pkgdir/usr/share/icons/hicolor/256x256/apps"' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Copy Flutter application files' >> /build/pkg/PKGBUILD && \\
    echo '  cp -r /app/* "\$pkgdir/opt/\$pkgname/"' >> /build/pkg/PKGBUILD
EOF

    # Conditionally add icon handling
    if [[ -f "$APP_ICON" ]]; then
        cat >> Dockerfile.arch << EOF
COPY "$APP_ICON" /build/icon.png
RUN echo '  cp "/build/icon.png" "\$pkgdir/usr/share/icons/hicolor/256x256/apps/\$pkgname.png"' >> /build/pkg/PKGBUILD
EOF
    fi

    # Continue PKGBUILD content
    cat >> Dockerfile.arch << EOF
RUN echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Create executable symlink' >> /build/pkg/PKGBUILD && \\
    echo '  ln -s "/opt/\$pkgname/$APP_NAME" "\$pkgdir/usr/bin/\$pkgname"' >> /build/pkg/PKGBUILD && \\
    echo '' >> /build/pkg/PKGBUILD && \\
    echo '  # Create desktop entry' >> /build/pkg/PKGBUILD && \\
    echo '  cat > "\$pkgdir/usr/share/applications/\$pkgname.desktop" << EOL' >> /build/pkg/PKGBUILD && \\
    echo '[Desktop Entry]' >> /build/pkg/PKGBUILD && \\
    echo 'Name=$APP_NAME' >> /build/pkg/PKGBUILD && \\
    echo 'Exec=\$pkgname' >> /build/pkg/PKGBUILD && \\
    echo 'Type=Application' >> /build/pkg/PKGBUILD && \\
    echo 'Categories=$APP_CATEGORY' >> /build/pkg/PKGBUILD
EOF

    # Conditionally add icon to desktop entry
    if [[ -f "$APP_ICON" ]]; then
        cat >> Dockerfile.arch << EOF
RUN echo 'Icon=/usr/share/icons/hicolor/256x256/apps/\$pkgname.png' >> /build/pkg/PKGBUILD && \\
    echo 'EOL' >> /build/pkg/PKGBUILD
EOF
    elif [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
        cat >> Dockerfile.arch << EOF
RUN echo 'EOL' >> /build/pkg/PKGBUILD && \\
    echo '  echo "Icon=/opt/\$pkgname/$BUNDLE_ICON_PATH" >> "\$pkgdir/usr/share/applications/\$pkgname.desktop"' >> /build/pkg/PKGBUILD
EOF
    else
        cat >> Dockerfile.arch << EOF
RUN echo 'EOL' >> /build/pkg/PKGBUILD
EOF
    fi

    # Complete the Dockerfile
    cat >> Dockerfile.arch << EOF
RUN echo '}' >> /build/pkg/PKGBUILD

# Create dummy sources - makepkg expects something
RUN touch /build/pkg/dummy

# Copy Flutter bundle
COPY $BUNDLE_DIR/ /app/

# Create a simple PKGBUILD that doesn't try to download anything
RUN cd /build/pkg && echo "# No sources needed - using prebuilt Flutter app" > /build/pkg/SRCINFO

# Set up build environment and run makepkg with nodeps
RUN mkdir -p /arch_output && \\
    useradd -m builder && \\
    chown -R builder:builder /build && \\
    chown -R builder:builder /app && \\
    chown -R builder:builder /arch_output && \\
    cd /build/pkg && \\
    sudo -u builder bash -c "makepkg --nodeps -f" && \\
    cp *.pkg.tar.zst /arch_output/ || (echo "Build failed" && cat /build/pkg/PKGBUILD && exit 1)

# Verify the package was created
RUN ls -la /arch_output/
EOF

    # Build with Docker
    docker build -t arch-builder -f Dockerfile.arch .

    # Extract package from the container
    echo "Extracting Arch Linux package from container..."
    docker create --name arch-extract arch-builder
    docker cp arch-extract:/arch_output/. "${OUTPUT_DIR}/"
    docker rm arch-extract

    # Check if package was extracted
    if ls "${OUTPUT_DIR}"/*.pkg.tar.zst &> /dev/null; then
        echo "✅ Arch Linux package created in ${OUTPUT_DIR}/ directory"
    else
        echo "❌ Arch Linux package creation failed - no package found"
        return 1
    fi

    # Clean up
    rm -f Dockerfile.arch
}

# 1. Create .deb package (Debian/Ubuntu)
if command -v dpkg-deb &> /dev/null && [[ "$NEEDS_DOCKER_FOR_DEB" == false ]]; then
    build_deb_native
elif command -v docker &> /dev/null && [[ "$NEEDS_DOCKER_FOR_DEB" == true ]]; then
    build_deb_docker
else
    echo "⚠️ Skipping .deb package creation - required tools not available"
    echo "   Install dpkg-dev package or Docker to build .deb packages"
fi

# 2. Create AppImage (Universal)
# Check if we can run AppImage on this system
if [[ "$IS_WINDOWS" == true ]]; then
    echo "⚠️ Skipping AppImage creation on Windows - not supported in this environment"
    echo "   Consider using WSL2 for AppImage creation"
else
    build_appimage
fi

# 3. Create RPM package (Fedora/RHEL)
if command -v rpmbuild &> /dev/null && [[ "$NEEDS_DOCKER_FOR_RPM" == false ]]; then
    build_rpm_native
elif command -v docker &> /dev/null && [[ "$NEEDS_DOCKER_FOR_RPM" == true ]]; then
    build_rpm_docker
else
    echo "⚠️ Skipping .rpm package creation - required tools not available"
    echo "   Install rpm-build package or Docker to build .rpm packages"
fi

# 4. Create Arch Linux package (.tar.zst)
if command -v makepkg &> /dev/null && [[ "$NEEDS_DOCKER_FOR_ARCH" == false ]]; then
    build_arch_native
elif command -v docker &> /dev/null && [[ "$NEEDS_DOCKER_FOR_ARCH" == true ]]; then
    build_arch_docker
else
    # If makepkg isn't available, create a basic PKGBUILD tarball
    echo "⚠️ Skipping .tar.zst package creation - required tools not available"
    echo "   Creating PKGBUILD tarball instead"

    # Create folder for PKGBUILD
    mkdir -p arch_package

    # Create PKGBUILD file
    cat > arch_package/PKGBUILD << EOF
# Maintainer: $MAINTAINER_NAME <$MAINTAINER_EMAIL>
pkgname=$APP_NAME
pkgver=$VERSION
pkgrel=1
pkgdesc="$APP_DESCRIPTION"
arch=('x86_64')
url="$REPO_URL"
license=('$APP_LICENSE')
depends=($ARCH_DEPENDENCIES)
options=(!strip)

package() {
  cd "\$srcdir"

  # Create installation directories
  install -d "\$pkgdir/usr/bin"
  install -d "\$pkgdir/opt/\$pkgname"
  install -d "\$pkgdir/usr/share/applications"

  # Copy Flutter application files
  cp -r src/* "\$pkgdir/opt/\$pkgname/"

  # Create executable symlink
  ln -s "/opt/\$pkgname/\$pkgname" "\$pkgdir/usr/bin/\$pkgname"

  # Create desktop entry
  cat > "\$pkgdir/usr/share/applications/\$pkgname.desktop" << EOL
[Desktop Entry]
Name=$APP_NAME
Exec=\$pkgname
Type=Application
Categories=$APP_CATEGORY
EOL
EOF

    # Add icon to PKGBUILD if available
    if [[ ! -z "$BUNDLE_ICON_PATH" ]]; then
        echo "  echo \"Icon=/opt/\$pkgname/$BUNDLE_ICON_PATH\" >> \"\$pkgdir/usr/share/applications/\$pkgname.desktop\"" >> arch_package/PKGBUILD
    fi

    # Complete the PKGBUILD file
    cat >> arch_package/PKGBUILD << EOF
}
EOF

    # Create source tarball from bundle
    mkdir -p arch_package/src
    cp -r $BUNDLE_DIR/* arch_package/src/

    # Compress PKGBUILD and src for manual distribution
    tar -czf "${OUTPUT_DIR}/${APP_NAME}-${VERSION}-PKGBUILD.tar.gz" -C arch_package .
    echo "✅ PKGBUILD created: ${OUTPUT_DIR}/${APP_NAME}-${VERSION}-PKGBUILD.tar.gz"
    echo "⚠️ Arch Linux users must extract this tar.gz file and run 'makepkg -si' to build and install the package."
fi

echo "🎉 All available packages created in ${OUTPUT_DIR}/ directory!"
echo ""
echo "Summary of created packages:"

# Check which packages were created and report
if [[ -f "${OUTPUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb" ]]; then
    echo "✅ .deb: ${APP_NAME}_${VERSION}_amd64.deb (Debian/Ubuntu/KDE Neon)"
else
    echo "❌ .deb: Not created"
fi

if [[ -f "${OUTPUT_DIR}/${APP_NAME}_${VERSION}-x86_64.AppImage" ]]; then
    echo "✅ AppImage: ${APP_NAME}_${VERSION}-x86_64.AppImage (Universal)"
else
    echo "❌ AppImage: Not created"
fi

if ls "${OUTPUT_DIR}/rpm_output"/*.rpm &> /dev/null; then
    echo "✅ .rpm: rpm_output/$(ls ${OUTPUT_DIR}/rpm_output/*.rpm | head -n1 | xargs basename) (Fedora/RHEL)"
else
    echo "❌ .rpm: Not created"
fi

if ls "${OUTPUT_DIR}"/*.pkg.tar.zst &> /dev/null; then
    echo "✅ .tar.zst: $(ls ${OUTPUT_DIR}/*.pkg.tar.zst | head -n1 | xargs basename) (Arch Linux)"
elif [[ -f "${OUTPUT_DIR}/${APP_NAME}-${VERSION}-PKGBUILD.tar.gz" ]]; then
    echo "✓ PKGBUILD: ${APP_NAME}-${VERSION}-PKGBUILD.tar.gz (Arch Linux)"
else
    echo "❌ Arch package: Not created"
fi

echo ""
echo "Installation instructions:"
echo "• .deb: sudo dpkg -i ${OUTPUT_DIR}/${APP_NAME}_${VERSION}_amd64.deb"
echo "• .rpm: sudo rpm -i ${OUTPUT_DIR}/rpm_output/*.rpm"
echo "• .tar.zst: sudo pacman -U ${OUTPUT_DIR}/*.pkg.tar.zst"
echo "• AppImage: chmod +x ${OUTPUT_DIR}/${APP_NAME}_${VERSION}-x86_64.AppImage && ./${OUTPUT_DIR}/${APP_NAME}_${VERSION}-x86_64.AppImage"
echo "• PKGBUILD: tar -xf ${OUTPUT_DIR}/${APP_NAME}-${VERSION}-PKGBUILD.tar.gz && cd extracted_dir && makepkg -si"