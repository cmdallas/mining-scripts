#!/usr/bin/env bash

# Pi3 CentOS Minimal bootstrap

# https://github.com/rharmonson/richtech/wiki/Using-CentOS-7.2.1511-Minimal-on-the-Raspberry-PI-3

systemctl
echo "NETWORKING=yes" > /etc/sysconfig/network

cat >> /etc/modprobe.d/raspi-blklst.conf <<EOL
#wifi
blacklist brcmfmac
blacklist brcmutil

#bt
blacklist btbcm
blacklist hci_uart
EOL

systemctl disable wpa_supplicant.service
systemctl stop NetworkManager firewalld
systemctl disable NetworkManager firewall

yum -y remove NetworkManager NetworkManager-libnm firewalldd
yum -y update yum
yum -y install iptables-services ruby gem vim yum-utils deltarpm tmux git
systemctl enable iptables
yum update -y

cat >> /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
IPADDR=10.0.0.100
NETMASK=255.255.255.0
GATEWAY=10.0.0.1
EOL

hostnamectl set-hostname #TODO
timedatectl set-timezone America/Los_Angeles

reboot
