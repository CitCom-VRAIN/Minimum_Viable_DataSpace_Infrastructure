#!/bin/bash

function decimal_to_ip {
    # Convert a decimal IP to dotted decimal notation
    local decimal=$1
    printf $(printf "%d.%d.%d.%d\n" $(($decimal >> 24)) $(($decimal >> 16 & 255)) $(($decimal >> 8 & 255)) $(($decimal & 255)))
}

function ip_to_decimal {
    # Convert a dotted decimal IP to decimal notation
    local ip=$1
    printf $(printf "%d\n" 0x$(printf "%02x" ${ip//./ }))
}


ip_range=$1
ip_offset=$2
# add default value if not set
if [ -z "$ip_range" ]; then
    ip_range=50
fi
# add default value if not set
if [ -z "$ip_offset" ]; then
    ip_offset=5
fi

################################################################################
# Get the docker IP range                                                      #
################################################################################
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Please install Docker." > /dev/stderr
    exit 1
fi
docker_network=$(docker network inspect -f '{{.IPAM.Config}}' kind | cut -d ' ' -f 1)
docker_network=${docker_network:2}

##################################################################################
# Check that the string result have a format of an IPv4 like: xxx.xxx.xxx.xxx/xx #
##################################################################################
if [[ $docker_network =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/[0-9]+$ ]]; then
    IFS='.' read -r -a octets <<< "$docker_network"
    valid=true
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            valid=false
            break
        fi
    done
    if $valid; then
        echo "Docker network: $docker_network" > /dev/stderr
    else
        echo "Error: Docker network contains invalid octet(s)." > /dev/stderr
        exit 1
    fi
else
    echo "Error: Docker network not found." > /dev/stderr
    exit 1
fi

################################################################################
# Get the mask in CIDR notation and convert it to netmask                      #
################################################################################
mask=$(echo $docker_network | cut -d '/' -f 2)
if ! command -v bc &> /dev/null; then
    echo "bc not found. Installing bc..." > /dev/stderr
    sudo apt-get update
    sudo apt-get install bc
fi
netmask=$(bc <<< "(2^32) - 2^(32-$mask)")
netmask=$(decimal_to_ip $netmask)
echo "Mask: $mask - Netmask: $netmask" > /dev/stderr

################################################################################
# Considering the mask, get the last possible IP address                       #
################################################################################
IFS='.' read -r -a network <<< "$docker_network"
IFS='.' read -r -a netmask <<< "$netmask"
for i in {0..3}; do
    ip[$i]=$((network[$i] | ~netmask[$i] & 255))
done
ip_broadcast="${ip[0]}.${ip[1]}.${ip[2]}.${ip[3]}"

################################################################################
# Considering the mask, subtract X adress from the last possible IP address    #
################################################################################
decimal_ip_broadcast=$(ip_to_decimal $ip_broadcast)

decimal_ip_last=$((decimal_ip_broadcast - ip_offset))
decimal_ip_first=$((decimal_ip_last - ip_range))

ip_last=$(decimal_to_ip $decimal_ip_last)
ip_first=$(decimal_to_ip $decimal_ip_first)
echo "IP range LoadBalancer: $ip_first-$ip_last" > /dev/stderr
echo "$ip_first-$ip_last"