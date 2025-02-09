#!/bin/bash
# This shell script is executed inside the chroot

echo Set hostname and point it to 127.0.0.1
echo "debian-live" > /etc/hostname
echo "127.0.0.1 debian-live" >> /etc/hosts

# Set as non-interactive so apt does not prompt for user input
export DEBIAN_FRONTEND=noninteractive

echo Install security updates and apt-utils
apt-get update
apt-get -y upgrade

echo Set locale
apt-get -y install locales
sed -i '/^#* *\(en\|sv\)_\(US\|SE\).UTF-8 UTF-8/s/^#* *//' /etc/locale.gen

dpkg-reconfigure --frontend=noninteractive locales
update-locale LANG=sv_SE.UTF-8

echo Install packages
apt-get install -y --no-install-recommends linux-image-amd64 live-boot
apt-get install -y $(cat ./packages.txt)

echo Clean apt post-install
apt-get clean

echo Enable systemd-networkd as network manager
systemctl enable systemd-networkd

echo Enable systemd-resolved as the resolver
systemctl enable systemd-resolved

echo Set resolv.conf to use systemd-resolved
rm /etc/resolv.conf
ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# echo Set root password
# echo "root:toor" | chpasswd

echo Remove machine-id
rm /etc/machine-id

echo List installed packages
dpkg --get-selections | tee /packages.txt
