#!/bin/bash
set -e

echo "================================================"
echo "Cleaning up Docker containers and volumes..."
echo "================================================"

APP_DIR="/home/vagrant/app"

# Navigate to app directory
cd "$APP_DIR"

# Stop and remove containers, networks, volumes
echo "Stopping containers..."
docker compose down -v

echo ""
echo "Removing unused Docker resources..."
docker system prune -af --volumes

echo ""
echo "Cleanup completed!"
echo ""