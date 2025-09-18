#!/usr/bin/env bash

set -e

echo "=== Step 1: Update system packages ==="
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    sudo apt update -y && sudo apt upgrade -y
elif [[ "$OSTYPE" == "darwin"* ]]; then
    brew update && brew upgrade
else
    echo "Unsupported OS: $OSTYPE"
    exit 1
fi

echo "=== Step 2: Check and install Git ==="
if ! command -v git &> /dev/null; then
    echo "Git not found. Installing..."
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y git
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install git
    fi
else
    echo "Git already installed."
fi

echo "=== Step 3: Install Docker ==="
if ! command -v docker &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y docker.io
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install --cask docker
        open /Applications/Docker.app
        echo "Please wait for Docker Desktop to finish starting..."
    fi
else
    echo "Docker already installed."
fi

echo "=== Step 4: Install Docker Compose ==="
if ! command -v docker-compose &> /dev/null; then
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt install -y docker-compose
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install docker-compose
    fi
else
    echo "Docker Compose already installed."
fi

echo "=== Step 5: Login to GitHub Container Registry ==="
echo "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" | docker login ghcr.io -u iqlab2025 --password-stdin

if [ $? -ne 0 ]; then
    echo "Docker login failed. Check your token."
    exit 1
fi

echo "=== Step 6: Start services with Docker Compose ==="
docker-compose up -d

echo "✅ Setup complete. Containers are running."
