#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <cluster_name>"
    exit 1
fi

cluster_name=$1

# Check if yq is installed and install it if not
if ! [ -x "$(command -v yq)" ]; then
    echo "yq is not installed. Installing it..."
    sudo add-apt-repository ppa:rmescandon/yq
    sudo apt update
    sudo apt install yq -y 
fi

output=$(kubectl config view --minify --flatten --context kind-$cluster_name --kubeconfig ~/.kube/config_terraform)

host=$(echo "$output" | yq e '.clusters[0].cluster.server' -)
client_certificate=$(echo "$output" | yq e '.users[0].user.client-certificate-data' -)
client_key=$(echo "$output" | yq e '.users[0].user.client-key-data' -)
cluster_ca_certificate=$(echo "$output" | yq e '.clusters[0].cluster.certificate-authority-data' -)

# Show the values
echo "- Host: $host"
echo "- Client Certificate: $client_certificate"
echo "- Client Key: $client_key"
echo "- Client CA Certificate: $cluster_ca_certificate"

# Write the values to a file
file_n="terraform.tfvars"
# Remove the file if it exists
if [ -f $file_n ]; then
    rm $file_n
fi
echo "host = \"$host\"" > $file_n
echo "client_certificate = \"$client_certificate\"" >> $file_n
echo "client_key = \"$client_key\"" >> $file_n
echo "cluster_ca_certificate = \"$cluster_ca_certificate\"" >> $file_n