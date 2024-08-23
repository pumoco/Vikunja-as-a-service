#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "This script must be run as root" 
   exit 1
fi

# Set variables
VIKUNJA_VERSION="0.24.2"  # replace with the desired version
INSTALL_DIR="/opt/vikunja"
VIKUNJA_SERVICE="/etc/systemd/system/vikunja.service"
DOMAIN="vikunja.LOL.LOL"  # replace with your domain
EMAIL="LOL@LOL.me"  # replace with your email for SSL cert
ZIP_FILE="vikunja-v${VIKUNJA_VERSION}-linux-amd64-full.zip"
UNZIPPED_FILE="vikunja-v${VIKUNJA_VERSION}-linux-amd64"  # The name of the file after unzipping
DOWNLOAD_URL="https://dl.vikunja.io/vikunja/$VIKUNJA_VERSION/$ZIP_FILE"  # replace with the actual URL

# Update and install necessary packages
apt-get update
apt-get install -y wget nginx certbot python3-certbot-nginx unzip

# Download Vikunja zip file
wget $DOWNLOAD_URL

# Wait until the file is completely downloaded
if [ ! -f "$ZIP_FILE" ]; then
    echo "Download failed or file not found."
    exit 1
fi

# Create the installation directory
mkdir -p $INSTALL_DIR

# Unzip the downloaded file to the installation directory
unzip $ZIP_FILE -d $INSTALL_DIR

# Make the binary executable
chmod +x $INSTALL_DIR/$UNZIPPED_FILE

# Create a symlink to the binary in /usr/bin
ln -s $INSTALL_DIR/$UNZIPPED_FILE /usr/bin/vikunja

# Create the Vikunja configuration file for SQLite
tee $INSTALL_DIR/config.yml > /dev/null <<EOL
database:
  type: sqlite
  path: $INSTALL_DIR/vikunja.db  # Path where the SQLite database file will be stored
EOL

# Create a systemd service file
echo "Creating systemd service file..."
tee $VIKUNJA_SERVICE > /dev/null <<EOL
[Unit]
Description=Vikunja
After=syslog.target
After=network.target

[Service]
RestartSec=2s
Type=simple
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/vikunja
Restart=always
# If you want to bind Vikunja to a port below 1024 uncomment
# the two values below
###
#CapabilityBoundingSet=CAP_NET_BIND_SERVICE
#AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd, enable and start the Vikunja service
systemctl daemon-reload
systemctl enable vikunja
systemctl start vikunja

# Clean up
rm $ZIP_FILE

# Install and configure Nginx
echo "Configuring Nginx..."
tee /etc/nginx/sites-available/vikunja > /dev/null <<EOL
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://127.0.0.1:3456;  # Vikunja default port
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOL

# Enable the Nginx configuration
ln -s /etc/nginx/sites-available/vikunja /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# Obtain SSL certificate with Certbot
echo "Obtaining SSL certificate for $DOMAIN..."
certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL

# Set up automatic certificate renewal
systemctl enable certbot.timer

echo "Vikunja has been installed, and your domain is configured with SSL."