#!/usr/bin/env bash

# Pi3 CentOS Minimal bootstrap

# https://github.com/rharmonson/richtech/wiki/Using-CentOS-7.2.1511-Minimal-on-the-Raspberry-PI-3

if [ $# -lt 4 ]
then
  echo "Please input hostname, ip address, netmask, gateway"
  echo "Example usage: ./${0##*/} monitoring1 10.0.0.100 255.255.255.0 10.0.0.1"
  echo "If you would like to configure AWS credentials plese use the following example:"
  echo "Example usage: ./${0##*/} monitoring1 10.0.0.100 255.255.255.0 10.0.0.1 access_key secret_key"
  exit 1
fi

hostname=$1
ip=$2
netmask=$3
gateway=$4
aws_access_key_id=$5
aws_secret_access_key=$6

remove_temp_files() {
  cd && rm -rf get-pip.py bootstrap_ruby_utils_yum.sh
}

echo -e "\e[36m== Finishing root filesystem expansion ==\e[0m"
resize2fs /dev/mmcblk0p3
echo -e "\e[32m   Done\e[0m"
echo ""

systemctl > /dev/null 2>&1
echo "NETWORKING=yes" > /etc/sysconfig/network

echo -e "\e[36m== Blacklisting wifi/bluetooth ==\e[0m"
cat > /etc/modprobe.d/raspi-blklst.conf <<EOL
#wifi
blacklist brcmfmac
blacklist brcmutil

#bt
blacklist btbcm
blacklist hci_uart
EOL
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Removing firewalld, enabling iptables, installing dependancies ==\e[0m"
systemctl disable wpa_supplicant.service
systemctl stop NetworkManager firewalld
systemctl disable NetworkManager firewall

yum -y remove NetworkManager NetworkManager-libnm firewalldd
yum -y update yum
yum -y install iptables-services ruby gem vim yum-utils deltarpm tmux
systemctl enable iptables
yum update -y

wget https://bootstrap.pypa.io/get-pip.py -O - | python
pip install awscli

mkdir ~/.aws/ && touch ~/.aws/credentials
cat > $_ <<EOL
[default]
aws_access_key_id = $aws_access_key_id
aws_secret_access_key = $aws_secret_access_key
EOL
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Assigning static IP address ==\e[0m"
cat >> /etc/sysconfig/network-scripts/ifcfg-eth0 <<EOL
DEVICE=eth0
TYPE=Ethernet
BOOTPROTO=none
ONBOOT=yes
IPADDR=$ip
NETMASK=$netmask
GATEWAY=$gateway
EOL
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Configuring hostname and timezone ==\e[0m"
hostnamectl set-hostname $hostname
timedatectl set-timezone America/Los_Angeles
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Bootstrapping cgminer-ruby-utils ==\e[0m"
gem install bundle rake
cd && git clone 'https://github.com/cmdallas/cgminer-ruby-utils.git'
rake -f ~/cgminer-ruby-utils/Rakefile build:all
bundle install --system --gemfile=~/cgminer-ruby-utils/Gemfile
find ~/cgminer-ruby-utils/bin -type f -exec chmod 755 {} \;
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Updating Cron for /root/cgminer-ruby-utils/bin/monitor_monitoring_nodes.rb==\e[0m"
cat >> /etc/crontab <<EOL
*/2 * * * * root /root/cgminer-ruby-utils/bin/monitor_monitoring_nodes.rb
EOL
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Configuring logrotate ==\e[0m"
cat > /etc/logrotate.d/logs <<EOL
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
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Removing temp files ==\e[0m"
remove_temp_files
echo -e "\e[32m   Done\e[0m"
echo ""

echo -e "\e[36m== Finished! ==\e[0m"
echo -e "\e[32m== Rebooting ==\e[0m"

reboot
