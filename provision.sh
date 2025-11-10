#!/bin/bash
set -euo pipefail

echo "================================================"
echo "Starting provisioning..."
echo "================================================"

# --- Determine project root dynamically ---
APP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="$APP_DIR/.env"
COMPOSE_FILE="$APP_DIR/docker-compose.yml"

echo "Project directory: $APP_DIR"

# --- Install Docker & Docker Compose if missing ---
if ! command -v docker &>/dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update -y
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update -y
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker

    echo "Docker installed successfully!"
    docker --version
    docker compose version || true
else
    echo "Docker is already installed."
fi

# --- Create .env from example if missing ---
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating .env file from .env.example..."
    if [ -f "$APP_DIR/.env.example" ]; then
        cp "$APP_DIR/.env.example" "$ENV_FILE"
        echo ".env file created."
    else
        echo "Warning: .env.example not found! Creating minimal .env..."
        cat <<EOF > "$ENV_FILE"
# Minimal default environment variables
POSTGRES_USER=postgres
POSTGRES_PASSWORD=secure_password_123
INVENTORY_DB_NAME=inventory_db
INVENTORY_DB_PORT=5432
BILLING_DB_NAME=billing_db
BILLING_DB_PORT=5433
RABBITMQ_USER=devopser
RABBITMQ_PASSWORD=devopser
RABBITMQ_HOST=rabbit-queue
RABBITMQ_PORT=5672
RABBITMQ_QUEUE=payment_queue
INVENTORY_APP_PORT=8080
BILLING_APP_PORT=8081
API_GATEWAY_PORT=3000
INVENTORY_SERVICE_URL=http://inventory-app:8080
BILLING_SERVICE_URL=http://billing-app:8080
EOF
        echo "Minimal .env created."
    fi
else
    echo ".env file already exists."
fi

# --- Ensure correct permissions ---
sudo chown -R $USER:$USER "$APP_DIR"

# --- Check docker-compose.yml ---
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "Error: docker-compose.yml not found in project directory."
    exit 1
fi

# --- Build and start containers ---
echo "Building and starting Docker containers..."
docker compose -f "$COMPOSE_FILE" build
docker compose -f "$COMPOSE_FILE" up -d

echo ""
echo "Waiting for services to stabilize..."
sleep 10

echo ""
echo "Container status:"
docker compose -f "$COMPOSE_FILE" ps

echo ""
echo "All containers should be running!"
echo "API Gateway available at: http://localhost:3000"
echo "Use 'docker compose logs -f' to view logs."
echo "================================================"
