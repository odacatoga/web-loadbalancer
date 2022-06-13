#!/bin/bash
# Usage: bash create-high-availability-vm-with-sets.sh <Resource Group Name>

RgName=”TraHoangViet-60”

date
# Create a Virtual Network for the VMs
echo '------------------------------------------'
echo 'Creating a Virtual Network for the VMs'
az network vnet create \
    --resource-group $RgName \
    --name travietVnet \
    --subnet-name travietSubnet 

# Create a Network Security Group
echo '------------------------------------------'
echo 'Creating a Network Security Group'
az network nsg create \
    --resource-group $RgName \
    --name travietNSG 

# Add inbound rule on port 80
echo '------------------------------------------'
echo 'Allowing access on port 80'
az network nsg rule create \
    --resource-group $RgName \
    --nsg-name travietNSG \
    --name Allow-80-Inbound \
    --priority 110 \
    --source-address-prefixes '*' \
    --source-port-ranges '*' \
    --destination-address-prefixes '*' \
    --destination-port-ranges 80 \
    --access Allow \
    --protocol Tcp \
    --direction Inbound \
    --description "Allow inbound on port 80."

# Create the NIC
for i in `seq 1 2`; do
  echo '------------------------------------------'
  echo 'Creating webNic'$i
  az network nic create \
    --resource-group $RgName \
    --name webNic$i \
    --vnet-name travietVnet \
    --subnet travietSubnet \
    --network-security-group travietNSG
done 

# Create an availability set
echo '------------------------------------------'
echo 'Creating an availability set'
az vm availability-set create -n portalAvailabilitySet -g $RgName

# Create 2 VM's from a template
for i in `seq 1 2`; do
    echo '------------------------------------------'
    echo 'Creating webVM'$i
    az vm create \
        --admin-username aztraviet \
        --resource-group $RgName \
        --name webVM$i \
        --nics webNic$i \
        --image UbuntuLTS \
        --availability-set portalAvailabilitySet \
        --generate-ssh-keys \
        --custom-data cloud-init.txt
done

# Done
echo '--------------------------------------------------------'
echo '             VM Setup Script Completed'
echo '--------------------------------------------------------'

#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - service nginx restart
  - [ 'sh', '-c', 'echo "<head><title>TRAHOANGVIET-60</title></head><body><h1>NAME: Tra Hoang Viet <br>MSSV: JK-ENR-HA-10360</h1><p>Web server: <strong>"`hostname`"</strong></p></body>" > /var/www/html/index.nginx-debian.html']


#cloud-config
package_upgrade: true
packages:
  - nginx
runcmd:
  - service nginx restart
  - [ 'sh', '-c', 'echo "<head><title>TRAHOANGVIET-60</title></head><body><h1>NAME: Tra Hoang Viet <br>MSSV: JK-ENR-HA-10360</h1><p>Web server: <strong>"`hostname`"</strong></p></body>" > /var/www/html/index.nginx-debian.html']
