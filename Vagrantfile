# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  
  config.vm.define "openldap" do |openldap|
    openldap.vm.box = "opensuse/openSUSE-42.1-x86_64"
    openldap.vm.hostname = "openldap.example.com"
    openldap.vm.network "private_network", ip: "192.168.50.100"
    openldap.vm.provision :puppet do |puppet|
      puppet.manifests_path  = "test"
      puppet.manifest_file  = "init.pp"
      puppet.module_path = ["modules", ".."]
      puppet.facter = { 'fqdn'  => openldap.vm.hostname }
    end
  end
  
end

