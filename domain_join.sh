#!/bin/bash

# Define the path to the inventory file
inventory_file="inventory.ini"

# Path to the ansible playbook
ansible_playbook_path="/ansible/acte11/git/DC2.0-Public-IICS/ansible/plays/centos-7-join-domain-sssd-tenant-ou/centos-7-join-domain-sssd-tenant-ou.yml"

# Read through each line of the inventory file
while IFS= read -r line; do
    # Skip the [servers] line
    if [[ "$line" == "[servers]" ]]; then
        continue
    fi

    # Check if the line contains the pattern 'IICS-SecureAgent-'
    if [[ $line == IICS-SecureAgent-* ]]; then
        # Extract the IP address
        IPADDRESS=$(echo "$line" | cut -d' ' -f2)

        # Extract the last two fields of the server name and format them
        HOSTNAME=$(echo "$line" | cut -d' ' -f1 | awk -F'-' '{print tolower($(NF-1)"-"$NF)}')

        # Construct the vm_hostname
        VM_HOSTNAME="nprod-$HOSTNAME"

        # Run the ansible playbook with the extracted variables
        echo "ansible-playbook -i $inventory_file $ansible_playbook_path -e 'vm_ipv4=$IPADDRESS' 'vm_hostname=$VM_HOSTNAME'"
        
        echo "Executed playbook for $VM_HOSTNAME with IP $IPADDRESS"
    fi
done < "$inventory_file"
