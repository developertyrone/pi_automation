#!/bin/bash

# Default values
INTERFACE="eth0"
DISABLE_WIFI="false"

# Read parameters
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --static_ip) STATIC_IP="$2"; shift ;;
        --router_ip) ROUTER_IP="$2"; shift ;;
        --dns_server) DNS_SERVER="$2"; shift ;;
        --disable_wifi) DISABLE_WIFI="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if STATIC_IP, ROUTER_IP, and DNS_SERVER are set
if [[ -z "$STATIC_IP" || -z "$ROUTER_IP" || -z "$DNS_SERVER" ]]; then
    echo "Error: STATIC_IP, ROUTER_IP, and DNS_SERVER must be provided."
    exit 1
fi

# Backup the current dhcpcd.conf
sudo cp /etc/dhcpcd.conf /etc/dhcpcd.conf.bak

# Add static IP configuration to dhcpcd.conf
sudo bash -c "cat >> /etc/dhcpcd.conf" <<EOL

interface $INTERFACE
static ip_address=$STATIC_IP/24
static routers=$ROUTER_IP
static domain_name_servers=$DNS_SERVER

EOL

# Restart the dhcpcd service to apply changes
sudo systemctl restart dhcpcd

echo "Static IP set to $STATIC_IP on $INTERFACE"

# Disable Wi-Fi if requested
if [ "$DISABLE_WIFI" == "true" ]; then
    sudo cp /boot/config.txt /boot/config.txt.bak
    echo "dtoverlay=disable-wifi" | sudo tee -a /boot/config.txt
    echo "Wi-Fi has been permanently disabled. Reboot to apply changes."
fi