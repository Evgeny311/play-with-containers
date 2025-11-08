# frozen_string_literal: true
require 'yaml'

# Load configuration
current_dir = File.dirname(File.expand_path(__FILE__))
configs = YAML.load_file("#{current_dir}/config.yaml", aliases: true, permitted_classes: [Symbol]) rescue YAML.load_file("#{current_dir}/config.yaml")
vagrant_config = configs['configs'][configs['configs']['use']]

BOX = "generic/ubuntu2204"
# Removed BOX_VERSION to use latest available for VirtualBox

def get_config(config, key)
  config[key] || raise("Missing configuration key: #{key}")
end

# VM addresses, CPU, memory
BILLING_VM_ADDR = get_config(vagrant_config, 'billing_vm_addr')
INVENTORY_VM_ADDR = get_config(vagrant_config, 'inventory_vm_addr')
GATEWAY_VM_ADDR = get_config(vagrant_config, 'gateway_vm_addr')

BILLING_VM_CPU = get_config(vagrant_config, 'billing_vm_cpu')
INVENTORY_VM_CPU = get_config(vagrant_config, 'inventory_vm_cpu')
GATEWAY_VM_CPU = get_config(vagrant_config, 'gateway_vm_cpu')

BILLING_VM_MEMORY = get_config(vagrant_config, 'billing_vm_memory')
INVENTORY_VM_MEMORY = get_config(vagrant_config, 'inventory_vm_memory')
GATEWAY_VM_MEMORY = get_config(vagrant_config, 'gateway_vm_memory')

# VM names
BILLING_VM = get_config(vagrant_config, 'billing_vm')
INVENTORY_VM = get_config(vagrant_config, 'inventory_vm')
GATEWAY_VM = get_config(vagrant_config, 'gateway_vm')

# App paths
BILLING_APP_SRC = get_config(vagrant_config, 'billing_app_src')
INVENTORY_APP_SRC = get_config(vagrant_config, 'inventory_app_src')
APIGATEWAY_APP_SRC = get_config(vagrant_config, 'apigateway_app_src')

BILLING_APP_PATH = get_config(vagrant_config, 'billing_app_path')
INVENTORY_APP_PATH = get_config(vagrant_config, 'inventory_app_path')
APIGATEWAY_APP_PATH = get_config(vagrant_config, 'apigateway_app_path')

# Environment variables with defaults
POSTGRES_PASSWORD = ENV['POSTGRES_PASSWORD'] || 'secure_password'

BILLING_DB_USER = ENV['BILLING_DB_USER'] || 'billing_user'
BILLING_DB_PASSWORD = ENV['BILLING_DB_PASSWORD'] || 'billing_pass'
BILLING_DB_NAME = ENV['BILLING_DB_NAME'] || 'billing_db'

INVENTORY_DB_USER = ENV['INVENTORY_DB_USER'] || 'inventory_user'
INVENTORY_DB_PASSWORD = ENV['INVENTORY_DB_PASSWORD'] || 'inventory_pass'
INVENTORY_DB_NAME = ENV['INVENTORY_DB_NAME'] || 'inventory_db'

RABBITMQ_USER = ENV['RABBITMQ_USER'] || 'rabbit_user'
RABBITMQ_PASSWORD = ENV['RABBITMQ_PASSWORD'] || 'rabbit_pass'
RABBITMQ_PORT = ENV['RABBITMQ_PORT'] || '5672'
RABBITMQ_QUEUE = ENV['RABBITMQ_QUEUE'] || 'payment_queue'

INVENTORY_APP_PORT = ENV['INVENTORY_APP_PORT'] || '5002'
APIGATEWAY_PORT = ENV['APIGATEWAY_PORT'] || '5000'
BILLING_APP_PORT = ENV['BILLING_APP_PORT'] || '5001'

Vagrant.configure("2") do |config|
  config.vm.box = BOX
  config.vm.box_check_update = true
  config.ssh.forward_agent = true
  config.vm.boot_timeout = 600

  # Removed deprecated env section
  # config.env.enable

  # VirtualBox provider global settings
  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--usb", "off"]
    vb.customize ["modifyvm", :id, "--usbehci", "off"]
  end

  # --- Billing VM ---
  config.vm.define BILLING_VM do |billing_vm|
    billing_vm.vm.hostname = BILLING_VM
    billing_vm.vm.network "private_network", ip: BILLING_VM_ADDR
    billing_vm.vm.network "forwarded_port", guest: 5001, host: 5001

    billing_vm.vm.provider "virtualbox" do |vb|
      vb.memory = BILLING_VM_MEMORY
      vb.cpus = BILLING_VM_CPU
      vb.name = BILLING_VM
    end

    billing_vm.vm.synced_folder BILLING_APP_SRC, BILLING_APP_PATH,
      type: 'virtualbox', owner: 'vagrant', group: 'vagrant'

    billing_vm.vm.provision "shell", name: "postgresql-setup",
      path: "scripts/postgresql-setup.sh",
      env: {
        "DB_USER" => BILLING_DB_USER,
        "DB_PASSWORD" => BILLING_DB_PASSWORD,
        "DB_NAME" => BILLING_DB_NAME,
      }

    billing_vm.vm.provision "shell", name: "rabbitmq-setup",
      path: "scripts/rabbitmq-setup.sh",
      env: {
        "RABBITMQ_USER" => RABBITMQ_USER,
        "RABBITMQ_PASSWORD" => RABBITMQ_PASSWORD,
      }

    billing_vm.vm.provision "shell", name: "python-setup",
      path: "scripts/py-setup.sh"

    billing_vm.vm.provision "shell", name: "run-billing-server",
      path: "scripts/run-py-server.sh",
      env: {
        "APP_PATH" => BILLING_APP_PATH,
        "APP_PORT" => BILLING_APP_PORT,
        "BILL_DB_HOST" => "localhost",
        "BILLING_DB_USER" => BILLING_DB_USER,
        "BILLING_DB_PASSWORD" => BILLING_DB_PASSWORD,
        "BILLING_DB_NAME" => BILLING_DB_NAME,
        "RABBITMQ_HOST" => "localhost",
        "RABBITMQ_PORT" => RABBITMQ_PORT,
        "RABBITMQ_USER" => RABBITMQ_USER,
        "RABBITMQ_PASSWORD" => RABBITMQ_PASSWORD,
        "RABBITMQ_QUEUE" => RABBITMQ_QUEUE,
      }
  end

  # --- Inventory VM ---
  config.vm.define INVENTORY_VM do |inventory_vm|
    inventory_vm.vm.hostname = INVENTORY_VM
    inventory_vm.vm.network "private_network", ip: INVENTORY_VM_ADDR
    inventory_vm.vm.network "forwarded_port", guest: 5002, host: 5002

    inventory_vm.vm.provider "virtualbox" do |vb|
      vb.memory = INVENTORY_VM_MEMORY
      vb.cpus = INVENTORY_VM_CPU
      vb.name = INVENTORY_VM
    end

    inventory_vm.vm.synced_folder INVENTORY_APP_SRC, INVENTORY_APP_PATH,
      type: 'virtualbox', owner: 'vagrant', group: 'vagrant'

    inventory_vm.vm.provision "shell", name: "postgresql-setup",
      path: "scripts/postgresql-setup.sh",
      env: {
        "DB_USER" => INVENTORY_DB_USER,
        "DB_PASSWORD" => INVENTORY_DB_PASSWORD,
        "DB_NAME" => INVENTORY_DB_NAME
      }

    inventory_vm.vm.provision "shell", name: "python-setup",
      path: "scripts/py-setup.sh"

    inventory_vm.vm.provision "shell", name: "run-inventory-server",
      path: "scripts/run-py-server.sh",
      env: {
        "APP_PATH" => INVENTORY_APP_PATH,
        "APP_PORT" => INVENTORY_APP_PORT,
        "INVENTORY_DB_USER" => INVENTORY_DB_USER,
        "INVENTORY_DB_PASSWORD" => INVENTORY_DB_PASSWORD,
        "INVENTORY_DB_NAME" => INVENTORY_DB_NAME,
        "INVENTORY_DB_HOST" => "localhost",
      }
  end

  # --- Gateway VM ---
  config.vm.define GATEWAY_VM do |gateway_vm|
    gateway_vm.vm.hostname = GATEWAY_VM
    gateway_vm.vm.network "private_network", ip: GATEWAY_VM_ADDR
    gateway_vm.vm.network "forwarded_port", guest: 5000, host: 5000

    gateway_vm.vm.provider "virtualbox" do |vb|
      vb.memory = GATEWAY_VM_MEMORY
      vb.cpus = GATEWAY_VM_CPU
      vb.name = GATEWAY_VM
    end

    gateway_vm.vm.synced_folder APIGATEWAY_APP_SRC, APIGATEWAY_APP_PATH,
      type: 'virtualbox', owner: 'vagrant', group: 'vagrant'

    gateway_vm.vm.provision "shell", name: "python-setup",
      path: "scripts/py-setup.sh"

    gateway_vm.vm.provision "shell", name: "run-gateway-server",
      path: "scripts/run-py-server.sh",
      env: {
        "APP_PATH" => APIGATEWAY_APP_PATH,
        "APP_PORT" => APIGATEWAY_PORT,
        "INVENTORY_APP_HOST" => INVENTORY_VM_ADDR,
        "INVENTORY_APP_PORT" => INVENTORY_APP_PORT,
        "RABBITMQ_HOST" => BILLING_VM_ADDR,
        "RABBITMQ_PORT" => RABBITMQ_PORT,
        "RABBITMQ_USER" => RABBITMQ_USER,
        "RABBITMQ_PASSWORD" => RABBITMQ_PASSWORD,
        "RABBITMQ_QUEUE" => RABBITMQ_QUEUE,
      }
  end
end
