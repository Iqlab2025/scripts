#!/usr/bin/env bash
set -e

echo "=== System bootstrap for Zabbix stack ==="

# Detect OS
OS="$(uname -s)"

# -------------------
# Ubuntu/Debian setup
# -------------------
if [ "$OS" = "Linux" ]; then
    echo "[*] Updating packages..."
    sudo apt update && sudo apt upgrade -y

    echo "[*] Checking Git..."
    if ! command -v git >/dev/null 2>&1; then
        echo "[*] Installing Git..."
        sudo apt install -y git
    else
        echo "[*] Git already installed."
    fi

    echo "[*] Checking Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        echo "[*] Installing Docker..."
        sudo apt install -y docker.io
        sudo systemctl enable docker
        sudo systemctl start docker
    else
        echo "[*] Docker already installed."
    fi

    echo "[*] Checking Docker Compose..."
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "[*] Installing Docker Compose..."
        sudo apt install -y docker-compose
    else
        echo "[*] Docker Compose already installed."
    fi
fi

# -------------------
# macOS setup
# -------------------
if [ "$OS" = "Darwin" ]; then
    echo "[*] macOS detected."

    echo "[*] Checking Homebrew..."
    if ! command -v brew >/dev/null 2>&1; then
        echo "[*] Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    echo "[*] Checking Git..."
    if ! command -v git >/dev/null 2>&1; then
        echo "[*] Installing Git..."
        brew install git
    fi

    echo "[*] Checking Docker..."
    if ! command -v docker >/dev/null 2>&1; then
        echo "[*] Installing Docker Desktop..."
        brew install --cask docker
        echo ">>> IMPORTANT: Start Docker Desktop manually at least once!"
    fi

    echo "[*] Checking Docker Compose..."
    if ! command -v docker-compose >/dev/null 2>&1; then
        echo "[*] Installing Docker Compose..."
        brew install docker-compose
    fi
fi

# -------------------
# Docker login
# -------------------
echo
echo ">>> Logging into GitHub Container Registry..."
read -p "Enter GitHub username: " GH_USER
read -s -p "Enter GitHub token: " GH_TOKEN
echo
echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USER" --password-stdin

# -------------------
# Run docker-compose
# -------------------
if [ -f "docker-compose.yml" ]; then
    echo "[*] Running docker-compose up -d..."
    docker-compose up -d
else
    echo "!!! docker-compose.yml not found in current directory."
fi
