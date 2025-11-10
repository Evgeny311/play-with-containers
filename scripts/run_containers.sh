#!/bin/bash
set -e

echo "================================================"
echo "Starting Docker containers..."
echo "================================================"

# Use current directory as app directory
APP_DIR="$(pwd)"

# Navigate to app directory
cd "$APP_DIR"

# Build and start containers
echo "Building and starting containers..."
docker compose up --build -d

echo ""
echo "Waiting for services to be ready..."
sleep 10

# Show container status
echo ""
echo "Container status:"
docker compose ps

echo ""
echo "All containers are running!"
echo ""
echo "Access the API at: http://localhost:3000"
echo "Run 'docker compose logs -f' to view logs"
echo ""
