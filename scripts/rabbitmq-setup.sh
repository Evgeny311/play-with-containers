#!/bin/bash
set -e

echo "=== RabbitMQ setup started ==="

# --- Install dependencies ---
apt-get update -y
apt-get install -y curl gnupg apt-transport-https software-properties-common

# --- Add Erlang repository and signing keys ---
echo "Adding Erlang repository..."
curl -1sLf "https://github.com/rabbitmq/signing-keys/releases/download/3.0/rabbitmq-release-signing-key.asc" | gpg --dearmor | tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

curl -1sLf "https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key" | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null

curl -1sLf "https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key" | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null

# --- Add Erlang and RabbitMQ repositories ---
echo "Configuring repositories..."
tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases
deb [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-erlang/deb/ubuntu jammy main

## Provides RabbitMQ
deb [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.novemberain.com/rabbitmq/rabbitmq-server/deb/ubuntu jammy main
EOF

# --- Update package list ---
apt-get update -y

# --- Install Erlang packages ---
echo "Installing Erlang..."
apt-get install -y erlang-base \
                   erlang-asn1 \
                   erlang-crypto \
                   erlang-eldap \
                   erlang-ftp \
                   erlang-inets \
                   erlang-mnesia \
                   erlang-os-mon \
                   erlang-parsetools \
                   erlang-public-key \
                   erlang-runtime-tools \
                   erlang-snmp \
                   erlang-ssl \
                   erlang-syntax-tools \
                   erlang-tftp \
                   erlang-tools \
                   erlang-xmerl

# --- Install RabbitMQ ---
echo "Installing RabbitMQ server..."
DEBIAN_FRONTEND=noninteractive apt-get install -y rabbitmq-server

# --- Enable and start RabbitMQ service ---
echo "Starting RabbitMQ service..."
systemctl enable rabbitmq-server
systemctl start rabbitmq-server

# Wait for RabbitMQ to fully start
sleep 5

# --- Enable management plugin ---
echo "Enabling management plugin..."
rabbitmq-plugins enable rabbitmq_management

# --- Create user and set permissions if not exist ---
if ! rabbitmqctl list_users | grep -q "${RABBIT_USER}"; then
    echo "Creating RabbitMQ user: ${RABBIT_USER}"
    rabbitmqctl add_user "${RABBIT_USER}" "${RABBIT_PASSWORD}"
    rabbitmqctl set_user_tags "${RABBIT_USER}" administrator
    rabbitmqctl set_permissions -p / "${RABBIT_USER}" ".*" ".*" ".*"
else
    echo "RabbitMQ user ${RABBIT_USER} already exists. Skipping creation."
fi

echo "=== RabbitMQ setup completed successfully ==="
echo "Management interface available at: http://localhost:15672"
echo "Username: ${RABBIT_USER}"