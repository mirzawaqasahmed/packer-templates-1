#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ vmware ]]; then
	echo "==> Installing VMware Tools"
	# Assuming the following packages are installed
	# apt-get install -y linux-headers-$(uname -r) build-essential perl

	if [[ -f /etc/centos-release ]]; then
		yum -y install git unzip wget patch net-tools
	else
		apt-get install -y git zip
	fi

	cd /tmp
	git clone https://github.com/rasa/vmware-tools-patches.git
	cd vmware-tools-patches
	./download-tools.sh 7.1.2
	./untar-and-patch-and-compile.sh
fi

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
	echo "==> Installing VirtualBox guest additions"
	# Assuming the following packages are installed:
	# apt-get install -y linux-headers-$(uname -r) build-essential perl
	# apt-get install -y dkms

	VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
	mount -o loop /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso /mnt
	sh /mnt/VBoxLinuxAdditions.run --nox11
	umount /mnt
	rm /home/vagrant/VBoxGuestAdditions_${VBOX_VERSION}.iso
	rm /home/vagrant/.vbox_version

	if [[ $VBOX_VERSION = "4.3.10" ]]; then
		ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions
	fi
fi
