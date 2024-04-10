#!/bin/bash

# Prompt for the domain name
read -p "Enter your domain name for the Wazuh dashboard: " YOUR_DOMAIN_NAME

# Step 1: Installing and configuring the certbot client

# Update system packages
apt-get update
# Install snapd
apt-get install snapd -y
# Ensure snapd is up to date
snap install core; snap refresh core
# Install certbot
snap install --classic certbot
# Make certbot accessible without full path
ln -s /snap/bin/certbot /usr/bin/certbot

# Step 2: Generate Let’s Encrypt SSL certificate

# Allow HTTP and HTTPS traffic
ufw allow 443
ufw allow 80
# Generate Let’s Encrypt certificate
certbot certonly --standalone -d $YOUR_DOMAIN_NAME

# Step 3: Configuring Let’s Encrypt SSL certificates in the Wazuh dashboard

# Copy the generated certificates to Wazuh dashboard directory
cp /etc/letsencrypt/live/$YOUR_DOMAIN_NAME/privkey.pem /etc/letsencrypt/live/$YOUR_DOMAIN_NAME/fullchain.pem /etc/wazuh-dashboard/certs/

# Modify /etc/wazuh-dashboard/opensearch_dashboards.yml to use Let’s Encrypt certificates
# Ensure you backup the original configuration before running the sed commands
sed -i "s|server.ssl.key: .*|server.ssl.key: \"/etc/wazuh-dashboard/certs/privkey.pem\"|g" /etc/wazuh-dashboard/opensearch_dashboards.yml
sed -i "s|server.ssl.certificate: .*|server.ssl.certificate: \"/etc/wazuh-dashboard/certs/fullchain.pem\"|g" /etc/wazuh-dashboard/opensearch_dashboards.yml

# Change the permissions and ownership of the certificate files
chown -R wazuh-dashboard:wazuh-dashboard /etc/wazuh-dashboard/
chmod -R 500 /etc/wazuh-dashboard/certs/
chmod 440 /etc/wazuh-dashboard/certs/privkey.pem /etc/wazuh-dashboard/certs/fullchain.pem

# Restart the Wazuh dashboard service
systemctl restart wazuh-dashboard

# Step 4: Configuring auto-renewal of the certificates

# Add renew_hook to certbot renewal configuration
echo "renew_hook = systemctl restart wazuh-dashboard" >> /etc/letsencrypt/renewal/$YOUR_DOMAIN_NAME.conf

# Test automatic renewal of the certificate
certbot renew --dry-run

echo "Configuration completed. Your Wazuh dashboard is now using Let's Encrypt certificates."
