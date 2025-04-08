# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/jammy64"
  config.ssh.forward_agent = true

  # Helper method to DRY up VM definitions
  def define_vm(config, name, ip)
    config.vm.define name do |vm|
      vm.vm.hostname = "#{name}.local"
      vm.vm.network "private_network", ip: ip
      vm.vm.provider "virtualbox" do |vb|
        vb.memory = "1024"
        vb.cpus = 2
      end
      vm.vm.provision "ansible" do |ansible|
        ansible.playbook = "provision.yml"
        ansible.inventory_path = "inventory.ini"
        ansible.vault_password_file = ".vault_pass.txt"
      end
    end
  end

  # Define VMs
  define_vm(config, "web", "192.168.56.10")
  define_vm(config, "db",  "192.168.56.11")
  define_vm(config, "app", "192.168.56.12")
end
