#!/bin/bash
# This script looks if the host has changed his IP and replaces it in /etc/hosts
# Used to backup laptops that constantly switch their Internet connection 
# between LAN or WLAN.

# Define all mac addresses of the host
MAC_ARRAY=( "54:e1:ad:a1:b2:c3" "54:e1:ad:d4:e5:f6" )

# Hostname in /etc/hosts
HOSTNAME="<hostname>"

# Functions ############################################
command_exists() {
    if ! [ -x "$(command -v $1)" ]; then
        echo "Error: $1 is not installed." >&2
        exit 1
    fi
}


# Main #################################################

# Check if used commands exists
command_exists grep
command_exists awk
command_exists sed


## Array Loop
for i in "${MAC_ARRAY[@]}"
do
    # Get the ip address from the arp table
    IP=$(grep $i /proc/net/arp | awk '{print $1}')

    # Check if there is an ip address 
    if [ -n ${IP} ] ; then
        echo "$IP Address found"
        sed -i "s/^.*${HOSTNAME}$/${IP}    ${HOSTNAME}/" /etc/hosts
    fi
done
# End