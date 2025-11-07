#!/bin/bash
# Simple TV Wake-on-LAN

# Add Homebrew to PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Load TV IP from .env file
if [ -f "$(dirname "$0")/../.env" ]; then
    TV_IP=$(grep "^TV_IP=" "$(dirname "$0")/../.env" | cut -d'=' -f2)
fi

# Fallback to default if not found
TV_IP=${TV_IP:-"10.0.0.75"}

# Try to get MAC address from ARP table
echo "Getting MAC address for TV at $TV_IP..."
MAC=$(arp -a | grep "$TV_IP" | awk '{print $4}' | head -1)

if [ -z "$MAC" ]; then
    echo "Pinging TV to populate ARP cache..."
    ping -c 1 "$TV_IP" >/dev/null 2>&1
    sleep 1
    MAC=$(arp -a | grep "$TV_IP" | awk '{print $4}' | head -1)
fi

if [ -z "$MAC" ]; then
    # Try alternative formats
    MAC=$(arp -n "$TV_IP" 2>/dev/null | awk '{print $3}' | head -1)
fi

if [ -z "$MAC" ] || [ "$MAC" = "(incomplete)" ]; then
    echo "Could not find MAC address for $TV_IP"
    echo "Current ARP table:"
    arp -a | grep -E "\.7[0-9]"
    exit 1
fi

echo "Found MAC: $MAC"
echo "Sending Wake-on-LAN packet..."

if command -v wakeonlan >/dev/null 2>&1; then
    wakeonlan "$MAC"
    echo "Wake-on-LAN packet sent to $TV_IP ($MAC)"
else
    echo "wakeonlan command not found"
    exit 1
fi