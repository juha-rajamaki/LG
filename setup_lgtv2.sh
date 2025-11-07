#!/bin/bash

# Setup script for lgtv2 control

echo "Setting up lgtv2 for LG TV control..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js first:"
    echo "  brew install node"
    exit 1
fi

# Check if npm is installed
if ! command -v npm &> /dev/null; then
    echo "npm is not installed. Please install Node.js/npm first:"
    echo "  brew install node"
    exit 1
fi

# Install lgtv2 globally
echo "Installing lgtv2..."
npm install -g lgtv2

# Create configuration
echo "Creating lgtv2 configuration..."
mkdir -p ~/.lgtv2
cat > ~/.lgtv2/config.json << EOF
{
  "tv": {
    "host": "10.0.0.75",
    "name": "LG TV"
  }
}
EOF

echo ""
echo "Setup complete!"
echo ""
echo "Now you can use these commands:"
echo "  lgtv2 --help                    # Show all commands"
echo "  lgtv2 connect 10.0.0.75         # Connect and pair with TV"
echo "  lgtv2 --powerOff                # Turn TV off"
echo "  lgtv2 --input HDMI_1            # Switch to HDMI 1"
echo "  lgtv2 --app netflix             # Launch Netflix"
echo "  lgtv2 --volume 20               # Set volume to 20"
echo "  lgtv2 --mute true               # Mute TV"
echo ""
echo "FIRST TIME SETUP:"
echo "1. Make sure your TV is ON"
echo "2. Run: lgtv2 connect 10.0.0.75"
echo "3. Accept the pairing request on your TV"
echo "4. The pairing will be saved for future use"