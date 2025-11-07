#!/bin/bash
# TV Helper - Find and configure TV settings

echo "🔍 TV Network Discovery Helper"
echo "This helps configure TV control for Travis"
echo ""

echo "1. Scanning network for LG TVs..."
nmap -p 3000-3001 10.0.0.0/24 2>/dev/null | grep -B 5 "3000\|3001" | grep "Nmap scan" | awk '{print $5}' | while read ip; do
    echo "Found potential TV at: $ip"
done

echo ""
echo "2. Checking ARP table for known devices..."
arp -a | grep -E "\\.61|LG|lg" || echo "No obvious TV found in ARP table"

echo ""
echo "3. Current TV configuration:"
echo "   IP: 10.0.0.61 (configured in tv_on.sh)"
echo ""

echo "To fix TV control:"
echo ""
echo "Option A - If you know your TV's MAC address:"
echo "   Edit tv_on.sh and set TV_MAC_MANUAL=\"aa:bb:cc:dd:ee:ff\""
echo ""
echo "Option B - Find TV on network:"
echo "   1. Turn on your TV"
echo "   2. Connect it to WiFi"  
echo "   3. Find its IP: Check router admin page or TV network settings"
echo "   4. Update TV_IP in tv_on.sh"
echo ""
echo "Option C - Disable TV control temporarily:"
echo "   Edit .env and set TV_CONTROL_ENABLED=false"