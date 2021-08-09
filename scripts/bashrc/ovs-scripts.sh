#!/bin/bash

# This script module offers various handy shortcuts
# for performing ovs operations

exec_print() {
	echo "Executing: $@"
	eval $@
}

ovslog() {
	exec_print sudo tail $1 /var/log/openvswitch/ovs-vswitchd.log
}

ovsrestart() {
	echo restart ovs... `(sudo service openvswitch-switch restart &>/dev/null || sudo service openvswitch restart &>/dev/null) && echo success || echo fail`
}

ovssethandlers() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:n-handler-threads=$1
}

ovssetrevalidators() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:n-revalidator-threads=$1
}

ovssethwoffload() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:hw-offload=$1
}

ovssetidle() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:max-idle=$1
}

ovssetpolicy() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:tc-policy=$1
}

ovssetconfig() {
	exec_print sudo ovs-vsctl set Open_vSwitch . other_config:$1
}

ovsremoveconfig() {
	exec_print sudo ovs-vsctl remove Open_vSwitch . other_config $1
}

ovsgetconfig() {
	if [ -z "$1" ]; then
		exec_print sudo ovs-vsctl get Open_vSwitch . other_config
	else
		exec_print sudo ovs-vsctl get Open_vSwitch . other_config:$1
	fi
}

ovsshow() {
	exec_print sudo ovs-vsctl show $@
}

ovsdshow() {
	exec_print sudo ovs-dpctl show $@
}

ovsddflows() {
	exec_print sudo ovs-appctl dpctl/dump-flows $@
}

ovsdoflows() {
	exec_print sudo ovs-ofctl dump-flows $@
}

_swap_recirc_id() {
	recirc_id=`echo $@ | grep -o -P "recirc_id\([0-9a-fx]*\)"`
	rest=`echo "$@" | sed 's/recirc_id[^,]*,//g'`
	echo "$recirc_id","$rest"
}

_sorted_dump_flow_swap_recirc_id() {
	sudo ovs-appctl dpctl/dump-flows $@ | while read x; do _swap_recirc_id $x; done | sort
}

ddumpct() {
	ports=`dshow | grep port | cut -d ":" -f 2 | grep -v internal`
	d=`_sorted_dump_flow_swap_recirc_id $@ --names | grep 'eth_type(0x0800)'`
	d_m=`_sorted_dump_flow_swap_recirc_id -m --names | grep 'eth_type(0x0800)'`

	for p in $ports; do
		echo "$d" | grep "in_port($p)" | while read x; do
			if [[ "" ]]; then
				act=`echo $x | grep -o "actions:.*"`
				d_mac=`echo "$x" | grep -o -P ",eth\(.*dst=\w+:\w+:\w+:\w+:\w+:\w+" | grep -o "dst=.*" | cut -d "=" -f 2`
				s_mac=`echo "$x" | grep -o -P ",eth\(src=\w+:\w+:\w+:\w+:\w+:\w+" | grep -o "src=.*" | cut -d "=" -f 2`

				m_rule=`echo "$d_m" | grep "in_port($p)" | grep -F "$act" | grep -F "$d_mac" | grep -F "$s_mac"`
				if [[ `echo "$m_rule" | wc -l` != 1 ]]; then
					echo "warn: bad parse"
					echo "dmac: $d_mac"
					echo "filtered rules:"
					echo "$m_rule"
					echo "skiping orig rule [$x]"
					echo ""
					continue
				fi

				offloaded=`echo "$m_rule" | grep -o -P "offloaded:\w+"`
				dp=`echo "$m_rule" | grep -o -P "dp:\w+"`

				echo $dp @ "$x" @ $offloaded
			else
				echo "$x" | grep "in_port($p)"
			fi
		done
		echo ""
	done
}

ddump() {
	_sorted_dump_flow_swap_recirc_id --names $@
}

nfconntrackclear() {
	exec_print sudo conntrack -F
}

nfconntrack() {
	exec_print sudo cat /proc/net/nf_conntrack
}

nfconntrack_offloaded() {
	res=`sudo cat /proc/net/nf_conntrack | grep -i offload` && echo "$res" && echo "$res" | wc -l
}

nfconntrack_offloadedcnt() {
	exec_print sudo cat /proc/net/nf_conntrack | grep -i offload | wc -l
}
