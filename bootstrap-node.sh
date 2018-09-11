# rke user MUST have docker rights (Cf. rke doc)
groupadd docker
systemctl restart docker
usermod -aG docker vagrant

# Remove iptable manager ; iptable rules should only be managed by kube-proxy
# No need for that in atomic host

# kubelet requires by default the swap to be turned off
swapoff -a
