# LG TV Control - Usage Examples

## Basic Power Control

### Turn TV On
```bash
./lgtv on
```
Output:
```
Turning TV ON...
Sending Wake-on-LAN packet to TV...
IP: 10.0.0.61
MAC: XX:XX:XX:XX:XX:XX
Wake-on-LAN packet sent successfully!
The TV should turn on within a few seconds.
```

### Turn TV Off
```bash
./lgtv off
```
Output:
```
Turning TV OFF...
Checking connection to TV at 10.0.0.61:3000...
TV is reachable. Sending power off command...
Power off command sent successfully!
The TV should turn off in a moment.
```

### Check TV Status
```bash
./lgtv status
```
Output when TV is on:
```
Checking TV status...
✓ TV is reachable at 10.0.0.61
✓ webOS API is accessible (TV is ON)
```

Output when TV is off:
```
Checking TV status...
✗ TV is not reachable (OFF or not connected to network)
```

## Input Switching

### Switch to HDMI Inputs
```bash
# Switch to HDMI 1 (e.g., cable box)
./lgtv input hdmi1

# Switch to HDMI 2 (e.g., PlayStation)
./lgtv input hdmi2

# Switch to HDMI 3 (e.g., Xbox)
./lgtv input hdmi3

# Switch to HDMI 4 (e.g., Apple TV box)
./lgtv input hdmi4
```

### Switch to Live TV
```bash
./lgtv input tv
```

### Launch Streaming Apps
```bash
# Open Netflix
./lgtv input netflix

# Open YouTube
./lgtv input youtube

# Open Amazon Prime Video
./lgtv input amazon

# Open Disney+
./lgtv input disney

# Open Apple TV+
./lgtv input apple

# Open HBO Max
./lgtv input hbo

# Open Spotify
./lgtv input spotify

# Open Web Browser
./lgtv input browser
```

## Common Scenarios

### Morning Routine - Turn on TV and go to news
```bash
# Turn on the TV
./lgtv on

# Wait a few seconds for TV to boot
sleep 10

# Switch to live TV for morning news
./lgtv input tv
```

### Movie Night - Turn on and launch Netflix
```bash
# Turn on the TV
./lgtv on

# Wait for TV to boot
sleep 10

# Launch Netflix
./lgtv input netflix
```

### Gaming Session - Switch to PlayStation on HDMI 2
```bash
# Check if TV is on
./lgtv status

# If TV is off, turn it on
./lgtv on
sleep 10

# Switch to HDMI 2 for PlayStation
./lgtv input hdmi2
```

### Bedtime - Turn everything off
```bash
# Turn off the TV
./lgtv off
```

## Automation Examples

### Create Aliases in ~/.zshrc or ~/.bash_profile
```bash
# Add these lines to your shell config
alias tv='./lgtv'
alias tvon='~/code/LG/lgtv on'
alias tvoff='~/code/LG/lgtv off'
alias netflix='~/code/LG/lgtv input netflix'
alias youtube='~/code/LG/lgtv input youtube'
alias ps5='~/code/LG/lgtv input hdmi2'
```

### Cron Job - Auto turn off TV at midnight
```bash
# Edit crontab
crontab -e

# Add this line to turn off TV at midnight every day
0 0 * * * /Users/borre/code/LG/lgtv off
```

### Script for Kids - Limited TV Time
```bash
#!/bin/bash
# kids_tv.sh - Allow 1 hour of YouTube

# Turn on TV and launch YouTube
~/code/LG/lgtv on
sleep 10
~/code/LG/lgtv input youtube

# Wait 1 hour
sleep 3600

# Turn off TV
~/code/LG/lgtv off
echo "TV time is over!"
```

## Troubleshooting Commands

### Check if wakeonlan is installed
```bash
which wakeonlan || echo "wakeonlan not installed - run: brew install wakeonlan"
```

### Test network connectivity to TV
```bash
ping -c 3 10.0.0.61
```

### Check if webOS port is accessible
```bash
nc -zv 10.0.0.61 3000
```

### Get TV's MAC address (when TV is on)
```bash
arp -n 10.0.0.61
```

## Error Messages and Solutions

### "Cannot connect to TV"
```bash
# This means the TV is off or not on network
# Solution: Check TV is powered on and connected to WiFi
./lgtv status
```

### "wakeonlan is not installed"
```bash
# Install wakeonlan using Homebrew
brew install wakeonlan
```

### "Could not determine MAC address"
```bash
# This happens when TV hasn't been seen on network yet
# Solution: Turn TV on manually once, then try:
ping -c 1 10.0.0.61
arp -a | grep 10.0.0.61
```