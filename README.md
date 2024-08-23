Vikunja Installation Script
This repository contains a Bash script to automate the installation and configuration of Vikunja on a Linux server. Vikunja is an open-source task management application that offers a self-hosted alternative to popular task management tools.

Features
Downloads and installs Vikunja version specified in the script.
Configures Vikunja with SQLite as the database.
Sets up and configures Nginx as a reverse proxy.
Obtains and installs an SSL certificate using Certbot.
Sets up a systemd service to manage Vikunja.
Prerequisites
Before running this script, ensure that your server meets the following requirements:

A Linux distribution that supports apt-get (e.g., Ubuntu, Debian).
Root or sudo access.
A registered domain name that points to your server's IP address.
Usage
1. Clone the Repository
```bash
git clone 
cd vikunja-install-script
```
2. Edit the Script
Open the install_vikunja.sh script in a text editor and modify the following variables according to your setup:

VIKUNJA_VERSION: The version of Vikunja you want to install.
DOMAIN: Your domain name where Vikunja will be accessible.
EMAIL: Your email address for SSL certificate registration.
3. Run the Script
Ensure the script is executable and then run it as root:


```bash
chmod +x install_vikunja.sh
sudo ./install_vikunja.sh
```
4. Access Vikunja
Once the script completes, you can access Vikunja through your web browser at https://yourdomain.com.

Script Overview
This script performs the following steps:

Environment Setup: Updates the package list and installs necessary packages (wget, nginx, certbot, python3-certbot-nginx, unzip).
Download and Install Vikunja: Downloads the specified version of Vikunja, unzips it, and sets up the binary and configuration files.
Systemd Service: Creates a systemd service for managing Vikunja, enabling it to start on boot and restart on failure.
Nginx Configuration: Sets up Nginx as a reverse proxy for Vikunja, handling requests on port 80 and forwarding them to Vikunja's default port (3456).
SSL Certificate: Uses Certbot to obtain an SSL certificate for your domain, ensuring secure access over HTTPS.
Clean-Up: Removes the downloaded files to keep your server clean.
Troubleshooting
Permission Issues: Ensure you are running the script as root or with sudo privileges.
Nginx Configuration Errors: If Nginx fails to restart, check the syntax of the configuration file using nginx -t.
SSL Certificate Issues: Make sure your domain is correctly pointing to your server's IP address and is accessible over the internet.