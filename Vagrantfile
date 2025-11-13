Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/focal64"

  # DNS Server
  config.vm.define "dns" do |dns|
    dns.vm.hostname = "dns"
    dns.vm.network "private_network", ip: "192.168.58.10"
    dns.vm.provision "shell", path: "dns.sh"
  end

  # DHCP Server
  config.vm.define "dhcp" do |dhcp|
    dhcp.vm.hostname = "dhcp"
    dhcp.vm.network "private_network", ip: "192.168.58.20"
    dhcp.vm.provision "shell", path: "dhcp.sh"
  end

  # Client Machine
  config.vm.define "client" do |client|
    client.vm.hostname = "client"
    # This machine will get its IP from the DHCP server
    client.vm.network "private_network", type: "dhcp"
    client.vm.provision "shell", path: "client.sh"
  end
end

