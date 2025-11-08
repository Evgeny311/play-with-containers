#!/bin/bash
set -e

echo "--- Installing PostgreSQL ---"
export DEBIAN_FRONTEND=noninteractive

# Обновляем список пакетов
apt-get update -y

# Проверяем наличие PostgreSQL
if ! command -v psql > /dev/null; then
    echo "Installing PostgreSQL from official repository..."
    apt-get install -y wget gnupg lsb-release

    # Добавляем официальный репозиторий PostgreSQL
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget -qO - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
    apt-get update -y

    # Устанавливаем PostgreSQL (актуальную доступную версию)
    apt-get install -y postgresql postgresql-contrib
fi

# --- Start PostgreSQL service ---
systemctl enable postgresql
systemctl start postgresql

# --- Find actual PGDATA folder ---
PGDATA=$(find /var/lib/postgresql/ -type d -name main | head -n 1)
CONF="$PGDATA/postgresql.conf"
HBA="$PGDATA/pg_hba.conf"

# --- Allow remote connections ---
if [ -f "$CONF" ]; then
  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$CONF"
fi

if [ -f "$HBA" ]; then
  grep -qxF "host all all 0.0.0.0/0 md5" "$HBA" || echo "host all all 0.0.0.0/0 md5" >> "$HBA"
fi

# --- Restart PostgreSQL ---
systemctl restart postgresql

# --- Create user and database ---
sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${DB_USER}'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';"

sudo -u postgres psql -lqt | cut -d \| -f 1 | grep -qw "${DB_NAME}" || \
    sudo -u postgres psql -c "CREATE DATABASE ${DB_NAME} OWNER ${DB_USER};"

echo "✅ PostgreSQL setup completed successfully."
