#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi



apt install curl sudo wget 
sudo curl http://osbpo.debian.net/osbpo/dists/pubkey.gpg | sudo apt-key add -
echo "deb http://osbpo.debian.net/osbpo bullseye-wallaby-backports main" | sudo tee -a /etc/apt/sources.list
echo "deb http://osbpo.debian.net/osbpo bullseye-wallaby-backports-nochange main" | sudo tee -a /etc/apt/sources.list
clear
echo "please change readline into high"
sleep 4
sudo dpkg-reconfigure -plow debconf
sudo apt update
sudo apt install -y python3-openstackclient mariadb-server python3-pymysql

echo "[mysqld]\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "bind-address = {controller_node_host_address}\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "default-storage-engine = innodb\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "innodb_file_per_table = on\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "max_connections = 4096\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf 
echo "collation-server = utf8_general_ci\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf
echo "character-set-server = utf8\n" >> /etc/mysql/mariadb.conf.d/99-openstack.cnf

sudo systemctl restart mysqld && sudo systemctl enable mysqld

===================================   controller node

sudo apt install python3-openstackclient mariadb-server python3-pymysql rabbitmq-server memcached python3-memcache keystone glance cinder-api cinder-scheduler cinder-volume cinder-backup placement-api nova-api nova-conductor nova-consoleproxy nova-scheduler neutron-server neutron-plugin-ml2 neutron-linuxbridge-agent neutron-l3-agent neutron-dhcp-agent neutron-metadata-agent 

===================================   compute node

sudo apt install -y nova-compute nova-compute-qemu neutron-linuxbridge-agent

===================================   dashboard

sudo apt install openstack-dashboard-apache


