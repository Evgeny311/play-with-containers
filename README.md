# Play-with-Containers - Microservices Architecture

A microservices-based application built with Vagrant, Docker, Docker Compose, Python Flask, PostgreSQL, and RabbitMQ. This project demonstrates containerization concepts running inside a Linux virtual machine and implements a simple movie inventory and billing system.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation](#installation)
- [Usage](#usage)
- [Utility Scripts](#utility-scripts)
- [API Documentation](#api-documentation)
- [Troubleshooting](#troubleshooting)
- [Technical Details](#technical-details)

## 🏗️ Architecture

The application runs inside a **Linux Virtual Machine** with Docker containers:
```
┌─────────────────────────────────────────────────────────────┐
│                      Host Machine                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Virtual Machine (Ubuntu 22.04)           │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │            Docker Engine                        │  │  │
│  │  │                                                 │  │  │
│  │  │  ┌─────────────────┐                          │  │  │
│  │  │  │   API Gateway   │ :3000 (External Access)  │  │  │
│  │  │  │  (api-gateway)  │                          │  │  │
│  │  │  └────────┬────────┘                          │  │  │
│  │  │           │                                    │  │  │
│  │  │      ┌────┴────┬──────────┐                   │  │  │
│  │  │      │         │          │                   │  │  │
│  │  │  ┌───▼───┐ ┌──▼──┐  ┌────▼────┐             │  │  │
│  │  │  │Inventory│ │Billing│ │RabbitMQ │             │  │  │
│  │  │  │  App   │ │ App  │ │ Queue   │             │  │  │
│  │  │  └───┬───┘ └──┬──┘  └─────────┘             │  │  │
│  │  │      │        │                               │  │  │
│  │  │  ┌───▼───┐ ┌──▼──┐                          │  │  │
│  │  │  │Inventory│ │Billing│                          │  │  │
│  │  │  │   DB   │ │  DB  │                          │  │  │
│  │  │  └───────┘ └─────┘                          │  │  │
│  │  │                                                 │  │  │
│  │  │  Docker Network: app-network                   │  │  │
│  │  └─────────────────────────────────────────────┘  │  │
│  │                                                     │  │
│  └───────────────────────────────────────────────────┘  │
│                                                           │
│  Port Forwarding: 3000 → VM:3000                        │
└─────────────────────────────────────────────────────────┘
```

### Services:

1. **api-gateway-app** - API Gateway that routes requests and queues orders
2. **inventory-app** - Manages movie inventory (CRUD operations)
3. **billing-app** - Manages orders and consumes RabbitMQ messages
4. **inventory-db** - PostgreSQL database for movies
5. **billing-db** - PostgreSQL database for orders
6. **rabbit-queue** - RabbitMQ message broker

## ✅ Prerequisites

- **VirtualBox** (version 6.1+ or 7.x)
- **Vagrant** (version 2.3+)
- **Git**
- At least **4GB of RAM** available for the VM

### Installation of Prerequisites

**Linux (Ubuntu/Debian):**
```bash
# Install VirtualBox
sudo apt-get update
sudo apt-get install virtualbox

# Install Vagrant
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update && sudo apt-get install vagrant
```

**macOS:**
```bash
# Using Homebrew
brew install --cask virtualbox
brew install --cask vagrant
```

**Windows:**
- Download and install [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Download and install [Vagrant](https://www.vagrantup.com/downloads)

## 📁 Project Structure
```
play-with-containers/
├── Vagrantfile              # Virtual machine configuration
├── .env.example            # Environment variables template
├── .gitignore             # Git ignore file
├── README.md             # This file
│
├── scripts/              # Provisioning scripts
│   ├── install_docker.sh        # Installs Docker in VM
│   ├── setup_environment.sh     # Sets up .env file
│   ├── run_containers.sh        # Starts Docker containers
│   └── clean_project.sh         # Cleans up containers
│
└── srcs/                # Application source code
    ├── docker-compose.yml      # Docker Compose configuration
    │
    ├── inventory-app/          # Inventory microservice
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   ├── server.py
    │   └── app/
    │       ├── __init__.py
    │       ├── config.py
    │       ├── models.py
    │       └── routes.py
    │
    ├── billing-app/           # Billing microservice
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   ├── server.py
    │   └── app/
    │       ├── __init__.py
    │       ├── config.py
    │       ├── models.py
    │       ├── routes.py
    │       └── consumer.py
    │
    ├── api-gateway-app/       # API Gateway
    │   ├── Dockerfile
    │   ├── requirements.txt
    │   ├── server.py
    │   └── app/
    │       ├── __init__.py
    │       ├── config.py
    │       └── proxy.py
    │
    ├── inventory-db/          # Inventory database
    │   ├── Dockerfile
    │   └── init.sql
    │
    ├── billing-db/            # Billing database
    │   ├── Dockerfile
    │   └── init.sql
    │
    └── rabbit-queue/          # RabbitMQ
        └── Dockerfile
```

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone <your-repo-url>
cd play-with-containers
```

### 2. Make Scripts Executable
```bash
chmod +x scripts/*.sh
```

### 3. Start the Virtual Machine
```bash
# This will:
# - Create Ubuntu VM
# - Install Docker
# - Build and start all containers
# Takes 5-10 minutes on first run
vagrant up
```

Expected output at the end:
```
╔════════════════════════════════════════════════════════════╗
║  Play with Containers - VM is ready!                       ║
╠════════════════════════════════════════════════════════════╣
║                                                            ║
║  🚀 API Gateway: http://localhost:3000                     ║
║                                                            ║
║  Useful commands:                                          ║
║  • vagrant ssh              - Access the VM                ║
║  • vagrant halt             - Stop the VM                  ║
║  • vagrant reload           - Restart the VM               ║
║  • vagrant destroy          - Delete the VM                ║
╚════════════════════════════════════════════════════════════╝
```

### 4. Verify Installation
```bash
# Check VM status
vagrant status

# Test API from host machine
curl http://localhost:3000/health

# Expected: {"status":"healthy","service":"api-gateway"}
```

### 5. Access the Virtual Machine (Optional)
```bash
# SSH into VM
vagrant ssh

# Inside VM, check containers
cd ~/app
docker compose ps
```

## 📖 Usage

### Basic Vagrant Commands
```bash
# Start the VM (if stopped)
vagrant up

# Stop the VM (preserves state)
vagrant halt

# Restart the VM
vagrant reload

# Restart and re-run provisioning
vagrant reload --provision

# Access the VM via SSH
vagrant ssh

# Check VM status
vagrant status

# Destroy the VM (deletes everything)
vagrant destroy -f

# Start fresh from scratch
vagrant destroy -f && vagrant up
```

### Inside the Virtual Machine
```bash
# SSH into VM first
vagrant ssh

# Navigate to project directory
cd ~/app

# View running containers
docker compose ps

# View logs of all services
docker compose logs -f

# View logs of specific service
docker compose logs -f api-gateway-app

# Restart all containers
docker compose restart

# Restart specific container
docker compose restart inventory-app

# Stop all containers
docker compose down

# Stop and remove volumes (fresh start)
docker compose down -v

# Rebuild after code changes
docker compose up --build -d

# Execute command in container
docker compose exec inventory-app sh
```

## 🔧 Utility Scripts

The project includes helper scripts in the `scripts/` directory that run during VM provisioning:

### Inside the VM
```bash
# SSH into VM
vagrant ssh

# Clean all containers and volumes (fresh start)
~/scripts/clean_project.sh

# Restart all containers
~/scripts/run_containers.sh
```

### Available Scripts

- **`install_docker.sh`** - Installs Docker and Docker Compose (runs automatically during `vagrant up`)
- **`setup_environment.sh`** - Sets up .env file from .env.example (runs automatically)
- **`run_containers.sh`** - Builds and starts all Docker containers
- **`clean_project.sh`** - Stops containers and removes all volumes

## 📚 API Documentation

### Base URL
```
http://localhost:3000
```

All requests from your **host machine** go through the forwarded port to the VM.

### Endpoints

#### Health Check
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "service": "api-gateway"
}
```

---

#### Get All Movies
```http
GET /api/movies
```

**Response:**
```json
[
  {
    "id": 1,
    "title": "The Matrix",
    "description": "A computer hacker learns about the true nature of reality",
    "price": 19.99,
    "stock": 50,
    "created_at": "2024-01-01T00:00:00",
    "updated_at": "2024-01-01T00:00:00"
  }
]
```

---

#### Get Movie by ID
```http
GET /api/movies/{movie_id}
```

**Example:**
```bash
curl http://localhost:3000/api/movies/1
```

**Response:**
```json
{
  "id": 1,
  "title": "The Matrix",
  "description": "A computer hacker learns about the true nature of reality",
  "price": 19.99,
  "stock": 50
}
```

---

#### Create Movie
```http
POST /api/movies
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "New Movie",
  "description": "Description here",
  "price": 15.99,
  "stock": 100
}
```

**Response:** `201 Created`

---

#### Create Order
```http
POST /api/orders
Content-Type: application/json
```

**Request Body:**
```json
{
  "user_id": 1,
  "movie_id": 1,
  "quantity": 2
}
```

**Response:**
```json
{
  "message": "Order received and queued for processing",
  "order_data": {
    "user_id": 1,
    "movie_id": 1,
    "movie_title": "The Matrix",
    "quantity": 2,
    "price": 19.99,
    "total_amount": 39.98
  }
}
```

**Note:** The order is sent to RabbitMQ queue and processed asynchronously by the billing-app.

---

#### Get All Orders
```http
GET /api/orders
```

**Response:**
```json
[
  {
    "id": 1,
    "user_id": 1,
    "movie_id": 1,
    "movie_title": "The Matrix",
    "quantity": 2,
    "price": 19.99,
    "total_amount": 39.98,
    "status": "processing",
    "created_at": "2024-01-01T00:00:00"
  }
]
```

---

#### Get Orders by User ID
```http
GET /api/orders/user/{user_id}
```

**Example:**
```bash
curl http://localhost:3000/api/orders/user/1
```

---

### Example Usage with curl
```bash
# Health check
curl http://localhost:3000/health

# Get all movies
curl http://localhost:3000/api/movies

# Get specific movie
curl http://localhost:3000/api/movies/1

# Create a new movie
curl -X POST http://localhost:3000/api/movies \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Inception",
    "description": "A thief who steals corporate secrets",
    "price": 24.99,
    "stock": 30
  }'

# Create an order
curl -X POST http://localhost:3000/api/orders \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "movie_id": 1,
    "quantity": 2
  }'

# Get all orders
curl http://localhost:3000/api/orders

# Get orders for specific user
curl http://localhost:3000/api/orders/user/1
```

## 🔍 Troubleshooting

### VM Fails to Start
```bash
# Check VirtualBox installation
VBoxManage --version

# Check Vagrant installation
vagrant --version

# View detailed logs
vagrant up --debug

# Destroy and recreate
vagrant destroy -f
vagrant up
```

### Port 3000 Already in Use
```bash
# Find process using port 3000
# On Linux/Mac:
lsof -i :3000

# On Windows (PowerShell):
netstat -ano | findstr :3000

# Kill the process or change port in Vagrantfile
```

### Container Issues Inside VM
```bash
# SSH into VM
vagrant ssh

# Check container status
cd ~/app
docker compose ps

# View logs
docker compose logs -f

# Restart containers
docker compose restart

# Clean and restart everything
~/scripts/clean_project.sh
~/scripts/run_containers.sh
```

### Database Connection Issues
```bash
# SSH into VM
vagrant ssh

# Check if database is ready
cd ~/app
docker compose exec inventory-db pg_isready -U postgres

# Access database directly
docker compose exec inventory-db psql -U postgres -d inventory_db

# View database logs
docker compose logs -f inventory-db
```

### RabbitMQ Issues
```bash
# SSH into VM
vagrant ssh

# Check RabbitMQ logs
cd ~/app
docker compose logs -f rabbit-queue

# Check RabbitMQ status
docker compose exec rabbit-queue rabbitmqctl status
```

### View Gateway Logs
```bash
# From host machine (via docker cp)
vagrant ssh -c "cd ~/app && docker compose exec api-gateway-app cat /var/log/gateway/gateway.log"

# Or SSH in and view
vagrant ssh
cd ~/app
docker compose exec api-gateway-app cat /var/log/gateway/gateway.log
```

### Reset Everything
```bash
# Complete reset - destroys VM and all data
vagrant destroy -f
vagrant up

# Or reset just containers (keeps VM)
vagrant ssh
~/scripts/clean_project.sh
~/scripts/run_containers.sh
```

### Making Code Changes
```bash
# 1. Edit files in srcs/ on your host machine
# 2. SSH into VM
vagrant ssh

# 3. Rebuild affected service
cd ~/app
docker compose up --build -d <service-name>

# Or rebuild all services
docker compose up --build -d
```

## 🔍 Technical Details

### Virtual Machine Specifications

- **OS**: Ubuntu 22.04 LTS (Jammy Jellyfish)
- **RAM**: 4GB
- **CPUs**: 2 cores
- **IP**: 192.168.56.10 (private network)
- **Docker**: Installed automatically
- **Docker Compose**: Installed automatically

### Docker Images

All images are built from **Alpine Linux** for minimal size:

- **Python services**: `python:3.11-alpine`
- **PostgreSQL**: `postgres:16-alpine`
- **RabbitMQ**: `rabbitmq:3.12-alpine`

### Docker Volumes

- `inventory-db` - Persists inventory database data
- `billing-db` - Persists billing database data
- `api-gateway-app` - Persists gateway logs at `/var/log/gateway`

### Docker Network

- **Network Name**: `app-network`
- **Driver**: bridge
- All services communicate internally via service names
- Only API Gateway (port 3000) is exposed to host machine

### Port Forwarding

- **3000:3000** - API Gateway (host → VM)
- All other services are internal to the VM

### Restart Policy

All containers have `restart: always` policy for automatic recovery from failures.

### Technology Stack

- **Virtualization**: Vagrant + VirtualBox
- **Containerization**: Docker + Docker Compose
- **Backend Framework**: Python Flask 3.0.3
- **ORM**: SQLAlchemy with Flask-SQLAlchemy
- **Database**: PostgreSQL 16
- **Message Queue**: RabbitMQ 3.12
- **HTTP Client**: requests library
- **Message Queue Client**: pika library

## 📝 Development Workflow

### 1. Start Development
```bash
# Start VM if not running
vagrant up

# SSH into VM
vagrant ssh

# Check services
cd ~/app
docker compose ps
```

### 2. Make Changes

Edit files in `srcs/` on your **host machine** (they're synced to VM automatically).

### 3. Apply Changes
```bash
# SSH into VM
vagrant ssh

# Rebuild affected service
cd ~/app
docker compose up --build -d <service-name>

# View logs
docker compose logs -f <service-name>
```

### 4. Test Changes
```bash
# From host machine
curl http://localhost:3000/api/movies
```

### Adding New Dependencies

1. Edit `requirements.txt` in the service directory
2. Rebuild the service:
```bash
vagrant ssh
cd ~/app
docker compose up --build -d <service-name>
```

### Database Migrations

To modify database schema:

1. Update `init.sql` in `srcs/inventory-db/` or `srcs/billing-db/`
2. Recreate database:
```bash
vagrant ssh
cd ~/app
docker compose down -v
docker compose up --build -d
```

## 📄 License

This project is part of the **Kood/Jõhvi** DevOps curriculum.

## 👥 Authors

#eandreyc

---

## 📌 Important Notes

- **Security**: Never commit `.env` file - it contains sensitive credentials
- **Performance**: VM requires minimum 4GB RAM
- **Networking**: Only port 3000 is exposed externally (API Gateway)
- **Data Persistence**: Docker volumes persist data between container restarts
- **Logs**: Gateway logs are stored in `/var/log/gateway/gateway.log` inside the container

---

**Note:** This project demonstrates microservices architecture, containerization with Docker running inside a virtual machine, message queuing with RabbitMQ, and API gateway pattern. It follows industry best practices for cloud-native applications and is designed for educational purposes.