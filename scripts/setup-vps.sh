#!/usr/bin/env bash

# Exit immediately if a command fails
set -e

echo "========================================="
echo "🛠️ Initializing VPS Environment..."
echo "========================================="

# Update package lists
echo "🔄 Updating APT repository..."
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key & repository if not already present
if ! command -v docker &> /dev/null; then
    echo "🐳 Installing Docker Engine..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# Enable and start Docker service
echo "⚡ Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to docker group
sudo usermod -aG docker $USER

echo "========================================="
echo "✅ VPS Setup complete! Please log out and back in to apply Docker group permissions."
echo "========================================="
