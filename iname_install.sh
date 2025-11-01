#!/bin/bash

# iname installation script
# Simple one-liner installer for the iname utility

set -e

INSTALL_DIR="${HOME}/.local/bin"
SCRIPT_NAME="iname"
SCRIPT_URL="https://raw.githubusercontent.com/IRodriguez13/Iname/main/iname.sh"

echo "Installing iname to ${INSTALL_DIR}..."

# Create directory if it doesn't exist
mkdir -p "${INSTALL_DIR}"

# Download the script
if command -v curl >/dev/null 2>&1; then
    curl -s -o "${INSTALL_DIR}/${SCRIPT_NAME}" "${SCRIPT_URL}"
elif command -v wget >/dev/null 2>&1; then
    wget -q -O "${INSTALL_DIR}/${SCRIPT_NAME}" "${SCRIPT_URL}"
else
    echo "Error: Neither curl nor wget available. Please install one of them."
    exit 1
fi

# Make executable
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"

# Check if in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo "Note: ${INSTALL_DIR} is not in your PATH."
    echo "Add this to your shell profile (~/.bashrc, ~/.zshrc, etc):"
    echo "export PATH=\"\${PATH}:${INSTALL_DIR}\""
    echo "Then run: source ~/.bashrc (or your shell config)"
fi

echo "Installation complete! Try: ${SCRIPT_NAME} --version"