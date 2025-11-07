#!/bin/bash

# LG TV Power Off using lgtv2
# More reliable method for newer LG webOS TVs

TV_IP="10.0.0.75"

# Check if lgtv2 is installed (global or local)
LGTV2_CMD=""
if command -v lgtv2 &> /dev/null; then
    LGTV2_CMD="lgtv2"
elif [ -f "./node_modules/.bin/lgtv2" ]; then
    LGTV2_CMD="./node_modules/.bin/lgtv2"
else
    echo "lgtv2 is not installed."
    echo "Run: npm install lgtv2"
    echo ""
    echo "Falling back to alternative methods..."
    exec "./tv_off_alt.sh"
fi

echo "Using Node.js WebSocket to turn off TV..."

# Try Node.js approach first
if [ -f "./tv_simple.js" ]; then
    node ./tv_simple.js off
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "TV turned off successfully!"
        exit 0
    else
        echo "Node.js method failed, trying alternative methods..."
    fi
fi

echo "Trying alternative methods..."
exec "./tv_off_alt.sh"