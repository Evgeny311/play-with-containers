#!/bin/bash
set -e

echo "================================================"
echo "Setting up environment..."
echo "================================================"

APP_DIR="/home/vagrant/app"

# Check if .env exists, if not create from .env.example
if [ ! -f "$APP_DIR/.env" ]; then
    echo "Creating .env file from .env.example..."
    cp "$APP_DIR/.env.example" "$APP_DIR/.env"
    echo ".env file created"
else
    echo "ℹ.env file already exists"
fi

# Set proper permissions
chown -R vagrant:vagrant "$APP_DIR"

echo ""
echo "Environment setup completed!"
echo ""