sudo keystone-manage bootstrap --bootstrap-password 123 \
  --bootstrap-admin-url http://192.168.1.132:5000/v3/ \
  --bootstrap-internal-url http://192.168.1.132:5000/v3/ \
  --bootstrap-public-url http://192.168.1.132:5000/v3/ \
  --bootstrap-region-id RegionOne



connection = mysql+pymysql://glance:123@192.168.1.132/glance

openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://192.168.1.132:9292
openstack endpoint create --region RegionOne image internal http://192.168.1.132:9292
openstack endpoint create --region RegionOne image admin http://192.168.1.132:9292


export OS_USERNAME=admin
export OS_PASSWORD=123
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://192.168.1.132:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2


CREATE DATABASE cinder;
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'localhost' IDENTIFIED BY '123';
GRANT ALL PRIVILEGES ON cinder.* TO 'cinder'@'%' IDENTIFIED BY '123';


openstack endpoint create --region RegionOne volumev3 public http://192.168.1.132:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://192.168.1.132:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://192.168.1.132:8776/v3/%\(project_id\)s


connection = mysql+pymysql://cinder:123@192.168.1.132/cinder

transport_url = rabbit://openstack:123@192.168.1.132



GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY '192.168.1.132';
GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY '192.168.1.132';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY '192.168.1.132';
GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY '192.168.1.132';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY '192.168.1.132';
GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY '192.168.1.132';



openstack endpoint create --region RegionOne compute public http://192.168.1.132:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://192.168.1.132:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://192.168.1.132:8774/v2.1



connection = mysql+pymysql://nova:123@192.168.1.132/nova_api
connection = mysql+pymysql://nova:{nova_database_password}@192.168.1.132/nova


openstack endpoint create --region RegionOne placement public http://192.168.1.132:8778
openstack endpoint create --region RegionOne placement internal http://192.168.1.132:8778
openstack endpoint create --region RegionOne placement admin http://192.168.1.132:8778



sudo systemctl restart cinder-api  cinder-backup cinder-volume cinder-scheduler apache2 
sudo systemctl enable cinder-api cinder-backup cinder-volume cinder-scheduler apache2

sudo systemctl restart nova-api nova-api-metadata nova-scheduler nova-conductor nova-spicehtml5proxy 
sudo systemctl enable nova-api nova-api-metadata nova-scheduler nova-conductor nova-spicehtml5proxy 
sudo systemctl stop nova-novncproxy 
sudo systemctl disable nova-novncproxy

sudo systemctl status nova-api nova-api-metadata nova-scheduler nova-conductor nova-spicehtml5proxy

sudo systemctl restart neutron-api && sudo systemctl restart neutron-l3-agent && sudo systemctl restart neutron-metadata-agent && sudo systemctl restart neutron-dhcp-agent && sudo systemctl restart neutron-linuxbridge-agent && sudo systemctl restart neutron-rpc-server && sudo systemctl enable neutron-api && sudo systemctl enable neutron-l3-agent && sudo systemctl enable neutron-metadata-agent && sudo systemctl enable neutron-dhcp-agent && sudo systemctl enable neutron-linuxbridge-agent && sudo systemctl enable neutron-rpc-server

sudo systemctl restart nova-api && sudo systemctl restart nova-scheduler && sudo systemctl restart nova-conductor && sudo systemctl restart nova-spicehtml5proxy


