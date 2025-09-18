#!/bin/bash
set -e  # exit if anything fails

echo "Updating system..."
if [ "$(uname)" == "Darwin" ]; then
    # macOS
    brew update || true
    if ! command -v git &> /dev/null; then
        echo "Installing Git..."
        brew install git
    fi
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker (you may need to install Docker Desktop manually on macOS)..."
        brew install --cask docker
    fi
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        brew install docker-compose
    fi
else
    # Ubuntu/Debian
    sudo apt update -y 
    if ! command -v git &> /dev/null; then
        echo "Installing Git..."
        sudo apt install -y git
    fi
    if ! command -v docker &> /dev/null; then
        echo "Installing Docker..."
        sudo apt install -y docker.io
    fi
    if ! command -v docker-compose &> /dev/null; then
        echo "Installing Docker Compose..."
        sudo apt install -y docker-compose
    fi

    echo "Enabling and starting Docker daemon..."
    sudo systemctl enable docker
    sudo systemctl start docker
fi

echo "Logging in to GitHub Docker Registry..."
echo "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" | docker login ghcr.io -u iqlab2025 --password-stdin

echo "Fetching docker-compose.yaml..."
curl -sSL https://raw.githubusercontent.com/Iqlab2025/scripts/main/docker-compose.yaml -o docker-compose.yaml

echo "Starting services with Docker Compose..."
docker compose up -d

echo "Setup complete!"
