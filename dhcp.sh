#!/bin/bash
# dhcp.sh - Provisioning script for DHCP Server (ISC-DHCP)

echo ">>> Updating package list"
apt-get update -y

echo ">>> Installing ISC DHCP Server"
apt-get install -y isc-dhcp-server

echo ">>> Waiting for DDNS key from dns server via /vagrant synced folder..."
while [ ! -f /vagrant/ddns.key ]; do
  sleep 2
done

echo ">>> Found ddns.key. Copying it to /etc/dhcp/"
cp /vagrant/ddns.key /etc/dhcp/ddns.key

echo ">>> Configuring dhcpd.conf"
cat > /etc/dhcp/dhcpd.conf <<EOF
# DDNS Configuration
ddns-update-style interim;
update-static-leases on;
log-facility local7;

# Include the DDNS key
include "/etc/dhcp/ddns.key";

# Global options
option domain-name "example.test";
option domain-name-servers 192.168.58.10;
default-lease-time 600;
max-lease-time 7200;
authoritative;

# Forward zone definition
zone example.test. {
  primary 192.168.58.10;
  key ddns-key;
}

# Reverse zone definition
zone 58.168.192.in-addr.arpa. {
  primary 192.168.58.10;
  key ddns-key;
}

# Subnet declaration
subnet 192.168.58.0 netmask 255.255.255.0 {
  range 192.168.58.100 192.168.58.200;
  option routers 192.168.58.1; # Assuming a gateway exists
}
EOF

echo ">>> Setting DHCP server to listen on the correct interface"
# For Ubuntu 20.04+, netplan is used. We will target the private network interface.
INTERFACE=$(ip -br a | grep 192.168.58.20 | awk '{print $1}')
sed -i "s/INTERFACESv4=\"\"/INTERFACESv4=\"$INTERFACE\"/" /etc/default/isc-dhcp-server

echo ">>> Restarting ISC DHCP Server"
systemctl restart isc-dhcp-server

echo "DHCP Server provisioning complete."
