# Kind Kubernetes development VM

This folder contains a sample `Vagrantfile` used to spin up a centos8 stream dev VM
optimized for running multiple containers and KIND(Kubernetes IN Docker)

## VM attributes
- CentOS8 stream based image
- Larger primary partition (32GB) to accomodate spinning up mulitple containers
- 4 CPUs, 8GB memory (edit file if needed)
- Provisioning script to set up golang development environment, docker and kind

## VM Network
we use vagrant private network and rely on the default NAT forwarding bridged network to egress to the
provider network.

when vagrant-libvirt is used, a sample network xml is provided (`vagrant-libvirt-network.xml`) and should be used to create a libvirt network prior to running `vagrant up` with the provided vagrant file.

Vagrantfile may be changed to support other network configuration, however it was tested with the
aforementioned network configuration.
