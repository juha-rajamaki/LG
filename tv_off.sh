#!/bin/bash

# LG TV Power Off Script
# Turns off the LG TV using webOS API

# Load TV IP from .env file
if [ -f "$(dirname "$0")/../.env" ]; then
    TV_IP=$(grep "^TV_IP=" "$(dirname "$0")/../.env" | cut -d'=' -f2)
fi

# Fallback to default if not found
TV_IP=${TV_IP:-"10.0.0.75"}
TV_PORT="3000"

# Function to check if TV is reachable
check_tv_connection() {
    nc -z -w2 "$TV_IP" "$TV_PORT" 2>/dev/null
    return $?
}

# Function to send power off command
send_power_off() {
    # webOS TVs accept simple HTTP commands on port 3000
    # This sends a power off command
    
    # First try with curl
    if command -v curl &> /dev/null; then
        curl -X POST \
             -H "Content-Type: application/json" \
             -d '{"id":"power_off","type":"request","uri":"ssap://system/turnOff"}' \
             "http://$TV_IP:$TV_PORT/roap/api/command" \
             --connect-timeout 5 \
             --silent \
             --output /dev/null
        return $?
    fi
    
    # Alternative: use nc (netcat) if curl is not available
    echo "Using netcat to send power off command..."
    echo -e 'POST /roap/api/command HTTP/1.1\r\nHost: '$TV_IP':'$TV_PORT'\r\nContent-Type: application/json\r\nContent-Length: 60\r\n\r\n{"id":"power_off","type":"request","uri":"ssap://system/turnOff"}' | nc "$TV_IP" "$TV_PORT"
}

echo "Checking connection to TV at $TV_IP:$TV_PORT..."

if ! check_tv_connection; then
    echo "Cannot connect to TV. Please ensure:"
    echo "  1. The TV is turned on"
    echo "  2. The TV is on the same network"
    echo "  3. LG Connect Apps is enabled in TV settings"
    echo ""
    echo "To enable remote control on your LG TV:"
    echo "  Settings > General > Network > LG Connect Apps > Turn On"
    exit 1
fi

echo "TV is reachable. Sending power off command..."

send_power_off

if [ $? -eq 0 ]; then
    echo "Power off command sent successfully!"
    echo "The TV should turn off in a moment."
else
    echo "Error sending power off command."
    echo ""
    echo "Alternative method: You may need to pair this device first."
    echo "Try using the LG TV Plus app on your phone to pair, then retry."
    exit 1
fi