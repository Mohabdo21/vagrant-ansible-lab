# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"
  config.ssh.forward_agent = true
  
  config.vm.define "web" do |web|
    web.vm.hostname = "web.local"
    web.vm.network "private_network", ip: "192.168.56.10"
    web.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 2
    end
    web.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
      ansible.inventory_path = "inventory.ini"
      ansible.vault_password_file = ".vault_pass.txt"
    end
  end
  
  config.vm.define "db" do |db|
    db.vm.hostname = "db.local"
    db.vm.network "private_network", ip: "192.168.56.11"
    db.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 2
    end
    db.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
      ansible.inventory_path = "inventory.ini"
      ansible.vault_password_file = ".vault_pass.txt"
    end
  end
  
  config.vm.define "app" do |app|
    app.vm.hostname = "app.local"
    app.vm.network "private_network", ip: "192.168.56.12"
    app.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
      vb.cpus = 2
    end
    app.vm.provision "ansible" do |ansible|
      ansible.playbook = "provision.yml"
      ansible.inventory_path = "inventory.ini"
      ansible.vault_password_file = ".vault_pass.txt"
    end
  end
end
