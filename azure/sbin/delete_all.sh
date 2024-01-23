#!/usr/bin/env bash

# リソースグループ名を設定
RESOURCE_GROUP="NetworkWatcherRG"

# リソースグループの存在確認
if [ "$(az group exists --name ${RESOURCE_GROUP})" == "false" ]; then
  echo "Error: Resource group ${RESOURCE_GROUP} does not exist."
  exit 1
fi

# VMの関連リソース（NICなど）の削除
echo "Deleting VM related resources in ${RESOURCE_GROUP}..."
vm_list=$(az vm list --resource-group ${RESOURCE_GROUP} --query "[].{name:name,nics:networkProfile.networkInterfaces[].id}" --output tsv)
for vm in $vm_list; do
  # VM関連のNICを削除
  nic_ids=$(echo $vm | awk '{print $2}')
  for nic_id in $nic_ids; do
    echo "Deleting NIC: $nic_id"
    az network nic delete --ids $nic_id
  done

  # VMを削除
  vm_name=$(echo $vm | awk '{print $1}')
  echo "Deleting VM: $vm_name"
  az vm delete --resource-group ${RESOURCE_GROUP} --name $vm_name --yes
done

# サブネットの削除
echo "Deleting subnets in ${RESOURCE_GROUP}..."
vnet_list=$(az network vnet list --resource-group ${RESOURCE_GROUP} --query "[].name" -o tsv)
for vnet in $vnet_list; do
  subnet_list=$(az network vnet subnet list --resource-group ${RESOURCE_GROUP} --vnet-name $vnet --query "[].name" -o tsv)
  for subnet in $subnet_list; do
    echo "Deleting subnet: $subnet in VNet: $vnet"
    az network vnet subnet delete --resource-group ${RESOURCE_GROUP} --vnet-name $vnet --name $subnet
  done
done

# VNetの削除
echo "Deleting VNets in ${RESOURCE_GROUP}..."
for vnet in $vnet_list; do
  echo "Deleting VNet: $vnet"
  az network vnet delete --resource-group ${RESOURCE_GROUP} --name $vnet
done

## 最終的にリソースグループを削除
#echo "Deleting resource group ${RESOURCE_GROUP}..."
#az group delete --name ${RESOURCE_GROUP} --yes --no-wait

echo "All resources in resource group ${RESOURCE_GROUP} have been released."
