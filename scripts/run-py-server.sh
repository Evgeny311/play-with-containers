#!/bin/bash
set -e

# Get parameters from environment variables OR positional arguments
APP_DIR="${APP_PATH:-$1}"
APP_NAME="${APP_NAME:-$(basename $APP_DIR 2>/dev/null || echo 'app')}"
APP_PORT="${APP_PORT:-${3:-8080}}"

echo "=== Starting $APP_NAME server ==="
echo "Application directory: $APP_DIR"
echo "Application port: $APP_PORT"

# --- Check if directory exists ---
if [ -z "$APP_DIR" ]; then
    echo "Error: APP_PATH/APP_DIR not provided!"
    exit 1
fi

if [ ! -d "$APP_DIR" ]; then
    echo "Error: Directory $APP_DIR does not exist!"
    echo "Listing /apps directory:"
    ls -la /apps/ 2>/dev/null || echo "Cannot access /apps"
    exit 1
fi

# --- Create venv in /opt (outside shared folder to avoid symlink issues) ---
VENV_DIR="/opt/venv-${APP_NAME}"

if [ -d "$VENV_DIR" ]; then
    echo "Removing old virtual environment..."
    rm -rf "$VENV_DIR"
fi

echo "Creating virtual environment in $VENV_DIR..."
python3 -m venv "$VENV_DIR"

# --- Activate virtual environment ---
echo "Activating virtual environment..."
source "$VENV_DIR/bin/activate"

# --- Upgrade pip ---
echo "Upgrading pip..."
pip install --upgrade pip

# --- Install Python packages ---
if [ -f "$APP_DIR/requirements.txt" ]; then
    echo "Installing dependencies from requirements.txt..."
    pip install --no-cache-dir -r "$APP_DIR/requirements.txt"
else
    echo "Error: requirements.txt not found in $APP_DIR"
    echo "Contents of directory:"
    ls -la "$APP_DIR"
    exit 1
fi

# --- Set environment variables for Flask ---
export FLASK_APP=server.py
export FLASK_ENV=development

# --- Create log directory if it doesn't exist ---
mkdir -p /var/log/apps

# --- Change to app directory and run the server ---
cd "$APP_DIR"

echo "Starting $APP_NAME server on port $APP_PORT..."
nohup python3 server.py > /var/log/apps/${APP_NAME}.log 2>&1 &

# --- Get the PID ---
SERVER_PID=$!
echo "Server started with PID: $SERVER_PID"

# --- Save PID to file ---
echo $SERVER_PID > /var/run/${APP_NAME}.pid

# --- Wait a bit and check if server is still running ---
sleep 3
if ps -p $SERVER_PID > /dev/null; then
    echo "✓ $APP_NAME server is running successfully!"
    echo "  Logs: /var/log/apps/${APP_NAME}.log"
    echo "  PID: $SERVER_PID"
    echo "  Port: $APP_PORT"
    echo "  Venv: $VENV_DIR"
else
    echo "✗ Failed to start $APP_NAME server."
    echo "Check logs below:"
    echo "----------------------------------------"
    tail -30 /var/log/apps/${APP_NAME}.log
    echo "----------------------------------------"
    exit 1
fi

echo "=== $APP_NAME server setup completed ==="