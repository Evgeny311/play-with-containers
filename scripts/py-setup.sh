#!/bin/bash
set -e

echo "=== Python app setup started ==="

# --- Install system dependencies ---
apt-get update -y
apt-get install -y python3 python3-pip python3-venv

# --- Create app directory ---
APP_DIR="/opt/app"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

# --- Set up Python virtual environment ---
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate

# --- Install Python dependencies (if requirements.txt exists) ---
if [ -f /vagrant/requirements.txt ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install -r /vagrant/requirements.txt
else
    echo "requirements.txt not found — skipping dependency installation."
fi

# --- Copy application code (if any) ---
if [ -d /vagrant/app ]; then
    cp -r /vagrant/app/* "$APP_DIR/"
fi

# --- Run database migrations or initialization (optional hook) ---
if [ -f "$APP_DIR/manage.py" ]; then
    echo "Running Django migrations..."
    python manage.py migrate
fi

echo "=== Python app setup completed successfully ==="
