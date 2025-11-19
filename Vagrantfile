# Vagrantfile - aprovisionamiento con ansible_local (BIND9 + ISC-DHCP + client)
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bulleseye64"

  # DNS
  config.vm.define "dns" do |dns|
    dns.vm.hostname = "dns"
    dns.vm.network "private_network", ip: "192.168.58.10"
    end

  # DHCP
  config.vm.define "dhcp" do |dhcp|
    dhcp.vm.hostname = "dhcp"
    dhcp.vm.network "private_network", ip: "192.168.58.20"

    end


  # Client (DHCP)
  config.vm.define "client" do |client|
    client.vm.hostname = "client"
    client.vm.network "private_network", type: "dhcp"
    end
  end


