#!/usr/bin/env bash
sbin="`dirname $0`"
sbin="`cd $sbin; pwd`"
source $sbin/common.sh

load_setting $1

az network nsg rule create --resource-group ${resource_group_name} --nsg-name allow_icmp --name Allow_ICMP --protocol ICMP --direction Inbound --priority 100 --source-address-prefix '*' --destination-address-prefix '*' --access Allow
