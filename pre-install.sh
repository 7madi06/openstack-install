#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi
############################      Installing prerequisites and keystone
ip=$(hostname -I)
Master_Password=123
sudo echo "controller_ip=\"${ip::-1}\"" >> /etc/environment

apt install curl sudo wget 

sudo apt install -y python3-openstackclient mariadb-server python3-pymysql chrony memcached python3-memcache
mysql_secure_installation
sudo apt update

sudo mysql < mysql/setup.sql

sed -i "s/-l 127.0.0.1/-l $controller_ip/" /etc/memcached.conf
echo "allow 192.0.0.0/1" >> /etc/chrony/chrony.conf
cp config/99-openstack.conf /etc/mysql/mariadb.conf.d/99-openstack.cnf

# echo "ETCD_NAME=\"controller\"
# ETCD_DATA_DIR=\"/var/lib/etcd\"
# ETCD_INITIAL_CLUSTER_STATE=\"new\"
# ETCD_INITIAL_CLUSTER_TOKEN=\"etcd-cluster-01\"
# ETCD_INITIAL_CLUSTER=\"controller=http://$controller_ip:2380\"
# ETCD_INITIAL_ADVERTISE_PEER_URLS=\"http://$controller_ip:2380\"
# ETCD_ADVERTISE_CLIENT_URLS=\"http://$controller_ip:2379\"
# ETCD_LISTEN_PEER_URLS=\"http://0.0.0.0:2380\"
# ETCD_LISTEN_CLIENT_URLS=\"http://$controller_ip:2379\"" >> /etc/default/etcd

sudo systemctl restart mysql chrony memcached
sudo systemctl enable mysql chrony memcached

sudo apt install -y keystone

sudo sed -e "s/sqlite\:\/\/\/\/var\/lib\/keystone\/keystone.db/mysql+pymysql\:\/\/keystone\:${Master_Password}@${ip}\/keystone/g" /etc/keystone/keystone.conf
sudo sed -i 's/\#provider/provider/g' /etc/keystone/keystone.conf
sudo keystone-manage db_sync
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

echo $ip' controller' >> /etc/hosts
keystone-manage bootstrap --bootstrap-password ADMIN_PASS \
--bootstrap-admin-url http://$ip:5000/v3/ \
--bootstrap-internal-url http://$ip:5000/v3/ \
--bootstrap-public-url http://$ip:5000/v3/ \
--bootstrap-region-id RegionOne

service apache2 restart

export OS_USERNAME=admin
export OS_PASSWORD=123
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://$controller_ip:5000/v3
export OS_IDENTITY_API_VERSION=3

sudo apt install -y python3-openstackclient

############################      Installing Glance

openstack project create service --domain default --description "Service Project"
openstack user create --domain default --password-prompt glance
openstack role add --project service --user glance admin
openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://$controller_ip:9292
openstack endpoint create --region RegionOne image internal http://$controller_ip:9292
openstack endpoint create --region RegionOne image admin http://$controller_ip:9292
sudo apt install -y glance
mv config/glance-api.conf /etc/glance/glance-api.conf
glance-manage db_sync
service glance-api restart

############################      Installing Placement

openstack role add --project service --user placement admin
openstack service create --name placement \
  --description "Placement API" placement
openstack endpoint create --region RegionOne \
  placement public http://$controller_ip:8778
openstack endpoint create --region RegionOne \
  placement internal http://$controller_ip:8778
openstack endpoint create --region RegionOne \
  placement admin http://$controller_ip:8778

sudo apt install -y placement-api
cp config/placement.conf /etc/placement/placement.conf
service placement-api restart
service apache2 restart

############################      Installing Nova

openstack user create --domain default --password-prompt nova
openstack role add --project service --user nova admin
openstack service create --name nova \
  --description "OpenStack Compute" compute
openstack endpoint create --region RegionOne \
  compute public http://$controller_ip:8774/v2.1
openstack endpoint create --region RegionOne \
  compute internal http://$controller_ip:8774/v2.1
openstack endpoint create --region RegionOne \
  compute admin http://$controller_ip:8774/v2.1
sudo apt install -y nova-api nova-conductor nova-novncproxy nova-scheduler

#   config file
  

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart

