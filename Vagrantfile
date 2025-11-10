# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  # Use Ubuntu 22.04 LTS
  config.vm.box = "ubuntu/jammy64"
  config.vm.box_check_update = true

  # VM Configuration
  config.vm.provider "virtualbox" do |vb|
    vb.name = "play-with-containers-vm"
    vb.memory = "4096"
    vb.cpus = 2
    vb.gui = false
  end

  # Network Configuration
  config.vm.hostname = "docker-vm"
  config.vm.network "private_network", ip: "192.168.56.10"
  
  # Port Forwarding - только API Gateway доступен снаружи
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "127.0.0.1"

  # Sync folders
  config.vm.synced_folder "./srcs", "/home/vagrant/app", 
    owner: "vagrant", 
    group: "vagrant"
  
  config.vm.synced_folder "./scripts", "/home/vagrant/scripts",
    owner: "vagrant",
    group: "vagrant"

  # Provision 1: Install Docker
  config.vm.provision "shell", 
    name: "install-docker",
    path: "scripts/install_docker.sh"

  # Provision 2: Setup Environment
  config.vm.provision "shell",
    name: "setup-environment", 
    path: "scripts/setup_environment.sh"

  # Provision 3: Run Containers
  config.vm.provision "shell",
    name: "run-containers",
    path: "scripts/run_containers.sh",
    privileged: false

  # Message after 'vagrant up'
  config.vm.post_up_message = <<-MESSAGE
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
    ║                                                            ║
    ║  Inside VM:                                                ║
    ║  • cd ~/app                      - Project directory       ║
    ║  • docker compose ps             - Container status        ║
    ║  • docker compose logs -f        - View logs               ║
    ║  • ~/scripts/clean_project.sh    - Clean everything        ║
    ║  • ~/scripts/run_containers.sh   - Restart containers      ║
    ║                                                            ║
    ╚════════════════════════════════════════════════════════════╝
  MESSAGE
end