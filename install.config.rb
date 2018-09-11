# -*- mode: ruby -*-
# vim: ft=ruby

# Configuration file ; default values are commented.

# Network configuration
#DOMAIN            = ".rke.k8s.test.local"
#NETWORK           = "10.42.1."                 # Private VM network (with host)
#NETMASK           = "255.255.255.0"

# Default Virtualbox .box
# See: https://app.vagrantup.com/bento
# Seealso : https://app.vagrantup.com/boxes/search
#BOX               = 'fedora/28-atomic-host'

# Main hosts declaration ; used to create the VM (Vagrant), and to provision k8s nodes (rke)
#HOSTS = {
#   # HOSTNAME => [ IP, RAM, CPU, type(master|worker) ]
#   "master-1" => [NETWORK+"10", 1536, 2, "master"],
#   # "master-2" => [NETWORK+"11", 1536, 2, "master"],
#   # "master-3" => [NETWORK+"12", 1536, 2, "master"],
#   "worker-1" => [NETWORK+"20", 1536, 2, "worker"],
#   # "worker-2" => [NETWORK+"21", 1536, 2, "worker"],
#   # "worker-3" => [NETWORK+"22", 1536, 2, "worker"],
#   # "worker-4" => [NETWORK+"23", 1536, 2, "worker"],
#   # "worker-5" => [NETWORK+"24", 1536, 2, "worker"],
}

