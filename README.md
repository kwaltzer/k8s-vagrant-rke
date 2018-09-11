Goal
====

These scripts allow to easily create a multi-node kubernetes cluster on a laptop for testing purposes. The initial goal was to study the failures modes of kubernetes by having a multi-node cluster in which it would be easy to inject failures (and to reinstall from scratch in case of real problems).

Disclaimer
==========

These scripts are only meant to be used for testing purposes only ! Even if they strive to create a environement relatively representative of a production kubernetes cluster (with notably different roles on different nodes and the activation of RBAC), the cluster comes with default configuration and with no hardening whatsoever !

Prerequisites
=============

* Vagrant (https://www.vagrantup.com/downloads.html)
* Virtualbox (https://www.virtualbox.org/wiki/Downloads)
* Host machine should be using either linux or macOS X

Usage
=====

Creation of the cluster
-----------------------

* Fill out the configuration file : `install.config.rb`
* Execute `install.sh`

This script downloads the required tools (kubectl & rke), creates the virtual machines, then provision the kubernetes cluster using rke (https://github.com/rancher/rke) (the rke manifest is created from infrastructure configuration through the `cluster.yml.erb` template).

To speed up the deployment, docker images (obtained with `docker images save` ; they can be gzipped) can be put inside the `.images` folder (this is especially useful for the hyperkube image)


Teardown of the cluster
-----------------------

* Execute `destroy.sh`

This script deletes all virtual machines (with their associated resources) and temporary manifests files.


Gotchas
=======

* Vagrant networking is kinda... strange. The first network interface must be a NAT, and its associated IP is set up by Vagrant and is the same everywhere... As this NAT interface is the default one (the default gateway allows to get stuff from external networks, like Internet resources), some additional configuration must be made (especially in some CNI providers) to cope with this.
* Spinning up large clusters puts a certain amount of stress on the network, as all containers will be downloaded from Internet. For infrastructure containers (e.g. hyperkube) and daemon sets, this can slow down the installation. The `.images` folder is one way to cope with this, but I would eventually need to provision and configure a docker caching repository along the way.
* Sometimes, the deployment of dashboard (for example) fails with the following error : `NetworkPlugin cni failed to set up pod "kubernetes-dashboard-7d5dcdb6d9-7pnzb_kube-system" network: failed to find plugin "loopback" in path [/opt/loopback/bin /opt/cni/bin]`. This seems to be a race condition between the cni plugin initialization and the dashboard deployment. In that case, delete the dashboard pod (k8s will recreate it with the correct configuration).
* rke uses its own flavours of kubernetes containers ; they aren't really different from official mainstream one (use container-diff to see the difference : `container-diff diff daemon://rancher/hyperkube:v1.11.2-rancher1 daemon://gcr.io/google_containers/hyperkube:v1.11.2`). Feel free to change them in the rke cluster configuration file to try vanilla ones.
* At last, this doesn't support installation behind a corporate proxy (ideally, proxy configuration for docker should be enough - in addition to the correct host proxy configuration, of course).

