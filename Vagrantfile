# -*- mode: ruby -*-
# vim: ft=ruby

# Bootstrap a k8s cluster with rke
# https://github.com/rancher/rke

require 'digest' # For mac address generation
require 'erb'

# ---- Configuration variables ----

### Default configuration ###

# Network configuration
DOMAIN            = ".rke.k8s.test.local"
NETWORK           = "10.42.1."                 # Private VM network (with host)
NETMASK           = "255.255.255.0"

# Default Virtualbox .box
# See: https://app.vagrantup.com/bento
# Seealso : https://app.vagrantup.com/boxes/search
#BOX               = 'centos/7'
BOX               = 'fedora/28-atomic-host'

# Main hosts declaration ; used to create the VM (Vagrant), and to provision k8s nodes (rke)
HOSTS = {
   # HOSTNAME => [ IP, RAM, CPU, type(master|worker) ]
   "master-1" => [NETWORK+"10", 1536, 2, "master"],
   "worker-1" => [NETWORK+"20", 1536, 2, "worker"],
}

### Load custom configuration ###

custom_variables = 'install.config.rb'
if File.exist?(custom_variables)
  load custom_variables
else
  abort("Configuration file '" + custom_variables + "' not found !")
end


# ---- rke cluster.yml configuration ----


## Render a custom cluster.yml for rke from the informations inside this vagrant file.
File.open('cluster.yml', 'w') do |f|
  f.write(ERB.new(File.read("cluster.yml.erb"),0,'<>').result())
end


# ---- Vagrant configuration ----

Vagrant.configure(2) do |config|

  # DNS handling.
  # Cf. https://github.com/devopsgroup-io/vagrant-hostmanager
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.vm.synced_folder ".", "/home/vagrant/sync", type: "rsync",
    rsync__exclude: [".git/",".images/"]

  HOSTS.each do | (name, cfg) |
    ipaddr, ram, cpus, hosttype = cfg

    config.vm.define name do |machine|
      machine.vm.box   = BOX

      machine.vm.provider "virtualbox" do |vbox|
        vbox.gui    = false
        vbox.cpus   = cpus
        vbox.memory = ram
        vbox.name   = "k8s-rke-"+name
      end

      machine.vm.hostname = name + DOMAIN
      machine.hostmanager.aliases = [ name ]

      machine.vm.network 'private_network', ip: ipaddr, netmask: NETMASK

      ### Following are things that don't really work ###s

      # Generate a base_mac for a custom mac adress (for eth0).
      # If we don't do this, every VM will have the same mac, so the same IP on the first interface.
      # Note : all virtualbox mac adresses seem to start with 525400 (vendor prefix)
      # Note bis : doesn't do anything.
      # machine.vm.base_mac = "525400" + (Digest::SHA256.hexdigest ipaddr)[0..5]
      
      # Allow login w/ our own ssh keys
      #config.ssh.forward_agent = true
      #config.ssh.keys_only = false
      #config.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"

    end
  end

  config.vm.provision "shell", path: "bootstrap-node.sh"
  config.vm.provision "file", source: ".images", destination: "/tmp/.images"
  config.vm.provision "shell", path: "bootstrap-images.sh"

end
