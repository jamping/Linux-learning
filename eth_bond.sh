#!/bin/sh
#Auto Make KVM Virtualization
#Auto config bond scripts
function eth_bond()
{
	NETWORK=(
		HWADDR=`ifconfig eth0 |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $1}'`
		IPADDR=`ifconfig eth0 |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $2}'`
		NETMASK=`ifconfig eth0 |egrep "HWaddr|Bcast" |tr "\n" " "|awk '{print $5,$7,$NF}'|sed -e 's/addr://g' -e 's/Mask://g'|awk '{print $3}'`
		GATEWAY=`route -n|grep "UG"|awk '{print $2}'`
	)
cat >ifcfg-bond0<<EOF
DEVICE=bond0
BOOTPROTO=static
${NETWORK[1]}
${NETWORK[2]}
${NETWORK[3]}
ONBOOT=yes
TYPE=Ethernet
NM_CONTROLLED=no
EOF
}

eth_bond