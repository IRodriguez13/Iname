#!/bin/bash

# iname installation script
# Universal installer for Linux and macOS

set -e

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="iname"

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Linux*)     echo "linux" ;;
        Darwin*)    echo "macos" ;;
        *)          echo "unknown" ;;
    esac
}

OS_TYPE=$(detect_os)

# Set the correct script URL based on OS
case "$OS_TYPE" in
    linux)
        SCRIPT_URL="https://raw.githubusercontent.com/IRodriguez13/Iname/master/iname.sh"
        ;;
    macos)
        SCRIPT_URL="https://raw.githubusercontent.com/IRodriguez13/Iname/master/iname-macos.sh"
        ;;
    *)
        echo "Error: Unsupported operating system: $(uname -s)"
        echo "This installer supports Linux and macOS only."
        exit 1
        ;;
esac

echo "Detected OS: $OS_TYPE"
echo "Installing iname to ${INSTALL_DIR}..."

# Create directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Download the script
echo "Downloading from: $SCRIPT_URL"
if command -v curl >/dev/null 2>&1; then
    if ! curl -s -f -o "${INSTALL_DIR}/${SCRIPT_NAME}" "${SCRIPT_URL}"; then
        echo "Error: Failed to download iname script"
        exit 1
    fi
elif command -v wget >/dev/null 2>&1; then
    if ! wget -q -O "${INSTALL_DIR}/${SCRIPT_NAME}" "${SCRIPT_URL}"; then
        echo "Error: Failed to download iname script"
        exit 1
    fi
else
    echo "Error: Neither curl nor wget available. Please install one of them."
    exit 1
fi

# Make executable
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

# Check if in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo ""
    echo "Note: ${INSTALL_DIR} is not in your PATH."
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc):"
    echo "export PATH=\"\${PATH}:${INSTALL_DIR}\""
    echo ""
    echo "Then run: source ~/.bashrc (or your shell config file)"
    echo ""
fi

echo "✅ Installation complete for $OS_TYPE!"
echo "Try: ${SCRIPT_NAME} --version"