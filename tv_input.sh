#!/bin/bash

# LG TV Input Switch Script
# Changes the input source on LG TV

# Load TV IP from .env file
if [ -f "$(dirname "$0")/../.env" ]; then
    TV_IP=$(grep "^TV_IP=" "$(dirname "$0")/../.env" | cut -d'=' -f2)
fi

# Fallback to default if not found
TV_IP=${TV_IP:-"10.0.0.75"}
TV_PORT="3000"

# Available input sources for LG webOS TVs
declare -A INPUTS=(
    ["hdmi1"]="com.webos.app.hdmi1"
    ["hdmi2"]="com.webos.app.hdmi2"
    ["hdmi3"]="com.webos.app.hdmi3"
    ["hdmi4"]="com.webos.app.hdmi4"
    ["tv"]="com.webos.app.livetv"
    ["netflix"]="netflix"
    ["youtube"]="youtube.leanback.v4"
    ["amazon"]="amazon"
    ["disney"]="com.disney.disneyplus-prod"
    ["apple"]="com.apple.appletv"
    ["hbo"]="com.hbo.hbomax"
    ["spotify"]="spotify-beehive"
    ["browser"]="com.webos.app.browser"
)

# Function to display available inputs
show_inputs() {
    echo "Available inputs:"
    echo "  HDMI:"
    echo "    hdmi1, hdmi2, hdmi3, hdmi4"
    echo "  Live TV:"
    echo "    tv"
    echo "  Apps:"
    echo "    netflix, youtube, amazon, disney, apple, hbo, spotify, browser"
}

# Function to check if TV is reachable
check_tv_connection() {
    nc -z -w2 "$TV_IP" "$TV_PORT" 2>/dev/null
    return $?
}

# Function to switch input
switch_input() {
    local input_name="$1"
    local app_id="${INPUTS[$input_name]}"
    
    if [ -z "$app_id" ]; then
        echo "Error: Unknown input '$input_name'"
        echo ""
        show_inputs
        exit 1
    fi
    
    echo "Switching to $input_name..."
    
    # Send launch app command
    if command -v curl &> /dev/null; then
        response=$(curl -X POST \
             -H "Content-Type: application/json" \
             -d '{"id":"launch_app","type":"request","uri":"ssap://system.launcher/launch","payload":{"id":"'$app_id'"}}' \
             "http://$TV_IP:$TV_PORT/roap/api/command" \
             --connect-timeout 5 \
             --silent \
             --write-out "\n%{http_code}")
        
        http_code=$(echo "$response" | tail -n1)
        
        if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
            echo "Successfully switched to $input_name!"
            return 0
        else
            echo "Failed to switch input (HTTP code: $http_code)"
            return 1
        fi
    else
        # Fallback to netcat
        echo "Using netcat to send input switch command..."
        payload='{"id":"launch_app","type":"request","uri":"ssap://system.launcher/launch","payload":{"id":"'$app_id'"}}'
        length=${#payload}
        
        echo -e "POST /roap/api/command HTTP/1.1\r\nHost: $TV_IP:$TV_PORT\r\nContent-Type: application/json\r\nContent-Length: $length\r\n\r\n$payload" | nc "$TV_IP" "$TV_PORT"
        
        echo ""
        echo "Input switch command sent to $input_name"
    fi
}

# Main script
if [ $# -eq 0 ]; then
    echo "Usage: $0 <input_name>"
    echo ""
    show_inputs
    exit 1
fi

INPUT="$1"

# Check connection
echo "Checking connection to TV at $TV_IP:$TV_PORT..."
if ! check_tv_connection; then
    echo "Cannot connect to TV. Please ensure:"
    echo "  1. The TV is turned on"
    echo "  2. The TV is on the same network"
    echo "  3. LG Connect Apps is enabled in TV settings"
    exit 1
fi

# Switch input
switch_input "$INPUT"