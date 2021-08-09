#!/bin/bash

# This script module offers various handy shortcuts
# for performing device operations such as configuring
# sriov, switchdev, unbind bind mlx driver for VF, PF, all VFs of PF

#get_vf <PF netdev> <vf index>
get_vf_netdev() {
	local pf=$1
    local vf=$2
    ls /sys/class/net/${pf}/device/virtfn${vf}/net
}

unbindvfs() {
	test "$1" && echo "unbindvfs, grep: $1"
	VFS_PCI=($(lspci | grep "Mellanox" | grep "Virtual" | cut -d " " -f 1))
	for i in ${VFS_PCI[@]}; do echo $i | grep "$1" &>/dev/null; test "$?" -ne 0 && continue; echo unbinding VF $i; sudo sh -c "echo 0000:${i} >> /sys/bus/pci/drivers/mlx5_core/unbind"; done
}

bindvfs() {
	test "$1" && echo "bindvfs, grep: $1"
	VFS_PCI=($(lspci | grep "Mellanox" | grep "Virtual" | cut -d " " -f 1))
	for i in ${VFS_PCI[@]}; do echo $i | grep "$1" &>/dev/null; test "$?" -ne 0 && continue; echo binding VF $i; sudo sh -c "echo 0000:${i} >> /sys/bus/pci/drivers/mlx5_core/bind"; done
}
