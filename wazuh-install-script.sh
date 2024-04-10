#!/bin/bash

# Function to display a text banner with LAN IP addresses
function display_banner() {
    echo "**************************************"
    echo "*  Wazuh Installation Script         *"
    echo "*  Created by Knippin ICT            *"
    echo "*  Automates the Wazuh Installation  *"
    echo "**************************************"
    echo "LAN IP Addresses:"
    ip -o -4 addr show | awk '{split($4, a, "/"); print a[1]}' | while read lan_ip; do
        echo "* ${lan_ip}"
    done
}

# Function to ask for the IP address
function ask_for_ip() {
    read -p "Enter the dashboard node Domain/FQDN: " dashboard_ip
    read -p "Enter the indexer node LAN IP: " indexer_ip
    read -p "Enter the Wazuh server (manager) LAN IP: " wazuh_manager_ip
    echo "dashboard node LAN IP: ${dashboard_ip}"
    echo "indexer node LAN IP: ${indexer_ip}"
    echo "Wazuh manager LAN IP: ${wazuh_manager_ip}"
}

# Function to select the Wazuh version for installation
function select_version() {
    echo "Select the Wazuh version you want to install:"
    versions=("4.7" "4.6" "4.5" "4.4" "4.3")
    select version in "${versions[@]}"; do
        if [[ " ${versions[*]} " =~ " ${version} " ]]; then
            echo "You have selected Wazuh version $version"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
}

# Main script
clear
display_banner
select_version
echo "This script automates the installation of Wazuh."
echo "Please follow the prompts to configure the installation."

# Step 1: Remove the existing config.yml
if [ -e "config.yml" ]; then
    rm -f config.yml
    echo "Existing config.yml removed."
fi

# Step 2: Download the new config.yml for the selected version
curl -o config.yml https://packages.wazuh.com/${version}/config.yml
echo "New config.yml for version ${version} downloaded."

# Step 3: Install Wazuh
echo "Installing the Wazuh indexer using the assistant"
ask_for_ip
echo "Installing... Please wait."

curl -o wazuh-install.sh https://packages.wazuh.com/${version}/wazuh-install.sh

# Replace IP placeholders in config.yml
sed -i "s/<dashboard-node-ip>/${dashboard_ip}/" config.yml
sed -i "s/<indexer-node-ip>/${indexer_ip}/" config.yml
sed -i "s/<wazuh-manager-ip>/${wazuh_manager_ip}/" config.yml

bash wazuh-install.sh --generate-config-files
bash wazuh-install.sh --wazuh-indexer node-1

echo "Installing the Wazuh server using the assistant"
bash wazuh-install.sh --wazuh-server wazuh-1

echo "Installing the Wazuh dashboard using the assistant"
# Attempt to install the dashboard
if ! bash wazuh-install.sh --wazuh-dashboard dashboard; then
    echo "Attempting to initialize the Wazuh indexer cluster and retry the dashboard installation..."
    bash wazuh-install.sh --start-cluster
    # Retry the dashboard installation after initializing the cluster
    bash wazuh-install.sh --wazuh-dashboard dashboard
fi

tar -xvf wazuh-install-files.tar wazuh-install-files/wazuh-passwords.txt

echo "Installation completed."
