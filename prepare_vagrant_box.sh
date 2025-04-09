#!/bin/bash

set -euo pipefail

log() {
	echo -e "\e[1;32m[INFO]\e[0m $*"
}

error_exit() {
	echo -e "\e[1;31m[ERROR]\e[0m $*" >&2
	exit 1
}

disable_swap() {
	log "Disabling swap..."
	sudo swapoff -a

	log "Removing swap entries from /etc/fstab..."
	sudo cp /etc/fstab /etc/fstab.bak
	sudo sed -i '/\bswap\b/d' /etc/fstab
	sudo systemctl daemon-reload

	local swap_file
	swap_file=$(grep -oP '^/[^ ]+' /etc/fstab.bak | grep swap || true)
	if [[ -n "$swap_file" && -f "$swap_file" ]]; then
		log "Removing swap file: $swap_file"
		sudo rm -f "$swap_file"
	else
		log "No swap file found or it was on a partition."
	fi

	free -h
	swapon --summary || log "Swap successfully disabled."
}

update_system() {
	log "Updating system..."
	sudo apt-get update
	sudo apt-get upgrade -y
	sudo apt-get dist-upgrade -y
	sudo apt-get autoremove -y
	sudo apt-get autoclean -y
}

install_packages() {
	log "Installing required packages..."
	sudo apt-get install -y git vim dkms build-essential linux-headers-$(uname -r) tree htop curl wget openssh-server
}

configure_sudoers() {
	log "Configuring passwordless sudo for vagrant user..."
	echo "vagrant ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/vagrant >/dev/null
	sudo chmod 0440 /etc/sudoers.d/vagrant
}

setup_ssh_keys() {
	log "Setting up Vagrant public key for SSH access..."
	mkdir -p /home/vagrant/.ssh
	touch /home/vagrant/.ssh/authorized_keys
	curl -fsSL https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub -o /home/vagrant/.ssh/authorized_keys
	chmod 600 /home/vagrant/.ssh/authorized_keys
}

install_guest_additions() {
	local version="7.1.6"
	local iso="VBoxGuestAdditions_${version}.iso"
	local mount_dir="/media/VBoxGuestAdditions"

	log "Installing VirtualBox Guest Additions v${version}..."
	wget -q "http://download.virtualbox.org/virtualbox/${version}/${iso}"
	sudo mkdir -p "$mount_dir"
	sudo mount -o loop,ro "$iso" "$mount_dir"
	sudo sh "$mount_dir/VBoxLinuxAdditions.run" || true
	sudo umount "$mount_dir"
	sudo rmdir "$mount_dir"
	rm -f "$iso"
}

finalize_box() {
	log "Clearing command history..."
	history -c
	unset HISTFILE

	log "Start and Enable ssh service..."
	sudo systemctl start ssh
	sudo systemctl enable ssh

	log "Shutting down system..."
	sudo poweroff
}

main() {
	update_system
	install_packages
	disable_swap
	configure_sudoers
	setup_ssh_keys
	install_guest_additions
	finalize_box
}

main "$@"
