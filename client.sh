#!/bin/bash
# client.sh - Provisioning script for the Client Machine

echo ">>> Updating package list"
apt-get update -y

echo ">>> Installing DNS utilities (dig, nslookup)"
apt-get install -y dnsutils

echo "Client machine provisioning complete."