# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.box = "ubuntu/focal64"
    config.vm.provision "file", source: "Dockerfile", destination: "/home/vagrant/Dockerfile"
    config.vm.provision "shell", path: "provision-vm.sh"
end
