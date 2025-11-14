#!/bin/bash
# dns.sh - Provisioning script for DNS Server (BIND9)

echo ">>> Updating package list"
apt-get update -y

echo ">>> Installing BIND9 and utilities"
apt-get install -y bind9 bind9utils

echo ">>> Generating DDNS key"
tsig-keygen -a hmac-sha256 ddns-key > /etc/bind/ddns.key
chown bind:bind /etc/bind/ddns.key
chmod 640 /etc/bind/ddns.key

echo ">>> Copying DDNS key to /vagrant for the DHCP server to use"
cp /etc/bind/ddns.key /vagrant/ddns.key

KEY_SECRET=$(grep secret /etc/bind/ddns.key | awk '{print $2}' | tr -d '";')

echo ">>> Configuring named.conf.options"
cat > /etc/bind/named.conf.options <<EOF
acl "trusted" {
    192.168.58.0/24;
    localhost;
    localnets;
};

options {
    directory "/var/cache/bind";
    recursion yes;
    allow-query { trusted; };
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    dnssec-validation auto;
    listen-on-v6 { any; };
};

include "/etc/bind/ddns.key";
EOF

echo ">>> Configuring named.conf.local"
cat > /etc/bind/named.conf.local <<EOF
zone "example.test" IN {
    type master;
    file "/var/lib/bind/db.example.test";
    allow-update { key "ddns-key"; };
};

zone "58.168.192.in-addr.arpa" IN {
    type master;
    file "/var/lib/bind/db.192";
    allow-update { key "ddns-key"; };
};
EOF

echo ">>> Creating forward zone file"
cat > /var/lib/bind/db.example.test <<EOF
$TTL    604800
@       IN      SOA     dns.example.test. root.example.test. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns.example.test.
dns     IN      A       192.168.58.10
dhcp    IN      A       192.168.58.20
EOF

echo ">>> Creating reverse zone file"
cat > /var/lib/bind/db.192 <<EOF
$TTL    604800
@       IN      SOA     dns.example.test. root.example.test. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      dns.example.test.
10      IN      PTR     dns.example.test.
20      IN      PTR     dhcp.example.test.
EOF

echo ">>> Setting permissions for zone files"
chown bind:bind /var/lib/bind/db.example.test
chown bind:bind /var/lib/bind/db.192

echo ">>> Restarting BIND9 service"
systemctl restart bind9

echo "DNS Server provisioning complete."