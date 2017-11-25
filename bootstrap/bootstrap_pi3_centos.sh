#!/usr/bin/env bash

# Pi3 CentOS Minimal bootstrap

# https://github.com/rharmonson/richtech/wiki/Using-CentOS-7.2.1511-Minimal-on-the-Raspberry-PI-3

if [ -z "$0" || "$1" ]
then
  echo "Please input AWS access/secret key for [default] user"
  echo "Example usage: ./${0##*/} aws_access_key_id aws_secret_access_key"
fi

bootstrap_ruby_utils() {
  echo "Bootstrapping cgminer-ruby-utils"
  cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git'
  rake -f ~/cgminer-ruby-utils/Rakefile build:all
  bundle install --system --gemfile= ~/cgminer-ruby-utils/Gemfile
  echo "Finished"
  exit 0
}

remove_temp_files() {
  cd && rm -rf get-pip.py bootstrap_ruby_utils_yum.sh
}

systemctl
echo "NETWORKING=yes" > /etc/sysconfig/network

cat > /etc/modprobe.d/raspi-blklst.conf <<EOL
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
yum -y install iptables-services ruby gem vim yum-utils deltarpm tmux wget
systemctl enable iptables
yum update -y

wget https://bootstrap.pypa.io/get-pip.py -O - | python
pip install awscli

mkdir ~/.aws/ && touch ~/.aws/credentials
cat >> $_ <<EOL
[default]
aws_access_key_id = $0
aws_secret_access_key = $1
EOL

cat >> /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
IPADDR=10.0.0.100
NETMASK=255.255.255.0
GATEWAY=10.0.0.1
EOL

cat >> /etc/logrotate.d/logs <<EOL
/var/log/cgminer-ruby-utils/logs {
size 100M
missingok
dateext
rotate 4
compress
notifempty
endscript
}
EOL

cat >> /etc/crontab <<EOL
*/2 * * * * root /root/cgminer-ruby-utils/bin/monitor_monitoring_nodes.rb
EOL

hostnamectl set-hostname #TODO
timedatectl set-timezone America/Los_Angeles

bootstrap_ruby_utils
find ~/cgminer-ruby-utils/bin -type f -exec chmod 755 {} \;

remove_temp_files

reboot
