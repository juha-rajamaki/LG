#!/bin/bash

# Alternative LG TV Power Off Script
# Uses different methods to turn off the TV

TV_IP="10.0.0.75"

echo "Attempting to turn off TV using multiple methods..."

# Method 1: Simple TCP command (some LG TVs accept this)
echo "Method 1: Sending simple power command..."
(echo "38:00:00:01:00"; sleep 1) | nc -w 2 "$TV_IP" 9761 2>/dev/null

# Method 2: HTTP GET request to trigger standby
echo "Method 2: Trying HTTP standby command..."
curl -X GET "http://$TV_IP:8080/roap/api/command/power" \
     --connect-timeout 2 \
     --silent \
     --output /dev/null 2>/dev/null

# Method 3: webOS SSAP command without pairing
echo "Method 3: Sending SSAP power command..."
{
    echo -n "type:request"
    echo -n "id:power_off"  
    echo -n "uri:ssap://system/turnOff"
    echo -n "payload:{}"
} | nc -w 2 "$TV_IP" 3000 2>/dev/null

# Method 4: LG HDMI-CEC simulation (if available)
echo "Method 4: Trying HDMI-CEC standby..."
echo -e '\x04\x36' | nc -w 2 "$TV_IP" 9761 2>/dev/null

echo ""
echo "Power off commands sent."
echo ""
echo "NOTE: If the TV doesn't turn off, you may need to:"
echo "1. Enable 'Mobile TV On' in your TV settings:"
echo "   Settings > General > Mobile TV On > Turn On"
echo ""
echo "2. Or use the LG ThinQ app to pair your device first"
echo ""
echo "3. Some LG TVs require authentication. Consider using:"
echo "   - LG ThinQ app for initial pairing"
echo "   - Then use 'pylgtv' Python library for control"
echo "   - Or 'lgtv2' npm package: npm install -g lgtv2"