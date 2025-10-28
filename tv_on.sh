#!/bin/bash

# LG TV Wake-on-LAN Script
# Turns on the LG TV using Wake-on-LAN (WOL)

TV_IP="10.0.0.61"
TV_MAC="" # Will be populated after ARP scan

# Function to get MAC address from IP
get_mac_address() {
    # Try to get MAC from ARP cache first
    MAC=$(arp -n "$TV_IP" 2>/dev/null | grep -v "incomplete" | awk '{print $3}' | grep -E "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}")
    
    if [ -z "$MAC" ]; then
        echo "TV not found in ARP cache. Pinging TV to populate ARP cache..."
        ping -c 1 -W 2 "$TV_IP" >/dev/null 2>&1
        sleep 1
        MAC=$(arp -n "$TV_IP" 2>/dev/null | grep -v "incomplete" | awk '{print $3}' | grep -E "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}")
    fi
    
    echo "$MAC"
}

# Check if wakeonlan is installed
if ! command -v wakeonlan &> /dev/null; then
    echo "wakeonlan is not installed. Installing..."
    
    # Check which package manager is available
    if command -v brew &> /dev/null; then
        brew install wakeonlan
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y wakeonlan
    elif command -v port &> /dev/null; then
        sudo port install wakeonlan
    else
        echo "Please install wakeonlan manually:"
        echo "  Ubuntu/Debian: sudo apt install wakeonlan"
        echo "  macOS: brew install wakeonlan"
        echo "  Fedora: sudo dnf install net-tools"
        exit 1
    fi
fi

# Get MAC address
TV_MAC=$(get_mac_address)

if [ -z "$TV_MAC" ]; then
    echo "Error: Could not determine MAC address for TV at $TV_IP"
    echo "Please make sure the TV is on the network and try again."
    echo ""
    echo "Alternatively, you can manually set the MAC address in this script."
    echo "Run 'arp -a | grep $TV_IP' when the TV is on to find its MAC address."
    exit 1
fi

echo "Sending Wake-on-LAN packet to TV..."
echo "IP: $TV_IP"
echo "MAC: $TV_MAC"

# Send WOL packet
wakeonlan "$TV_MAC"

if [ $? -eq 0 ]; then
    echo "Wake-on-LAN packet sent successfully!"
    echo "The TV should turn on within a few seconds."
    echo ""
    echo "Note: Wake-on-LAN must be enabled on your TV:"
    echo "  Settings > General > Network > Wake-on-LAN"
else
    echo "Error sending Wake-on-LAN packet."
    exit 1
fi