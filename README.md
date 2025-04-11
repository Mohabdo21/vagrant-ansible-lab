# Vagrant-Ansible Lab Environment

This project provides a virtualized lab environment using **Vagrant** and **Ansible** for provisioning a multi-node Ubuntu infrastructure. It’s perfect for practicing system automation, learning Ansible roles, and simulating production-like setups on your local machine.

<!--toc:start-->
- [Vagrant-Ansible Lab Environment](#vagrant-ansible-lab-environment)
  - [📦 Project Structure](#-project-structure)
  - [🧱 VMs Layout](#-vms-layout)
  - [🚀 Getting Started](#-getting-started)
    - [1. Clone the Repository](#1-clone-the-repository)
    - [2. Prepare Secrets](#2-prepare-secrets)
    - [3. Create a ssh key pair for the user `mohannad`](#3-create-a-ssh-key-pair-for-the-user-mohannad)
    - [4. Launch the VMs](#4-launch-the-vms)
    - [5. SSH into a VM](#5-ssh-into-a-vm)
  - [🔧 Features](#-features)
  - [📜 Tips](#-tips)
  - [🛡️ Security](#️-security)
<!--toc:end-->

## 📦 Project Structure

```

.
├── Vagrantfile # Defines the VM topology (web, db, app)
├── provision.yml # Main Ansible playbook
├── inventory.ini # Ansible inventory (web, db & app groups)
├── roles/
│ ├── common/ # Common tasks for all nodes
│ ├── web/ # Web server-specific configuration
│ ├── db/ # Database-specific configuration
│ └── app/ # Application-specific configuration
├── secrets.yml # Vault-encrypted secrets (passwords, keys)
└── .vault_pass.txt # Password file to decrypt secrets.yml

```

## 🧱 VMs Layout

| Role | Hostname    | IP              | CPU | RAM  |
| ---- | ----------- | --------------- | --- | ---- |
| Web  | `web.local` | `192.168.56.10` | 2   | 1024 |
| DB   | `db.local`  | `192.168.56.11` | 2   | 1024 |
| App  | `app.local` | `192.168.56.12` | 2   | 1024 |

> You can scale easily by defining multiple web/db/app VMs in `Vagrantfile`.

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Mohabdo21/vagrant-ansible-lab.git
cd vagrant-ansible-lab
```

### 2. Prepare Secrets

Create and encrypt your `secrets.yml` file with user passwords:

```bash
ansible-vault create secrets.yml
```

Content example:

```yaml
plain_root_password: your_root_password
plain_mohannad_password: your_mohannad_password
```

Save your vault password to `.vault_pass.txt`.

### 3. Create a ssh key pair for the user `mohannad`

```bash
ssh-keygen -t rsa -b 4096 -C "mohannad@local" -f ~/.ssh/id_rsa_vagrant
```

### 4. Launch the VMs

```bash
vagrant up
```

This will:

- Create and start the VMs.
- Run Ansible playbooks to provision each node.

### 5. SSH into a VM

```bash
vagrant ssh web
vagrant ssh db
vagrant ssh app
```

## 🔧 Features

- Automatic swap setup (1GB)
- Common packages installed (Git, curl, vim, etc.)
- User creation with sudo access
- Secure password and SSH key setup via Ansible Vault
- Role-based provisioning (common, web, db, app)
- Reboots VMs if necessary after provisioning

## 📜 Tips

- Re-provision: `vagrant provision`
- Destroy and rebuild: `vagrant destroy -f && vagrant up`
- Customize IPs and hostnames in `Vagrantfile`
- Adjust tasks per role under `roles/` directory

## 🛡️ Security

- Use Ansible Vault to store any secrets (passwords, keys)
- Never commit `.vault_pass.txt` or decrypted secrets to GitHub
