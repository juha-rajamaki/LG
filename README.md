# LG TV Control - Command Line TV Controller

Control your LG WebOS TV from the terminal using shell scripts and network commands. Can be launched standalone or integrated with other programs like the ChatGPT Voice assistant.

## Setup

1. Ensure your TV and computer are on the same network
2. Enable Wake-on-LAN on your TV:
   - Settings > General > Network > Wake-on-LAN > On
3. Enable LG Connect Apps:
   - Settings > General > Network > LG Connect Apps > On

## Quick Start

### Main Control Script
```bash
./lgtv [command]
```

**Commands:**
- `./lgtv on` - Turn TV on
- `./lgtv off` - Turn TV off  
- `./lgtv status` - Check if TV is reachable
- `./lgtv input hdmi1` - Switch to HDMI 1
- `./lgtv input netflix` - Launch Netflix

### Individual Scripts
```bash
./tv_on.sh              # Turn on TV
./tv_off.sh             # Turn off TV
./tv_input.sh hdmi1     # Switch to HDMI 1
```

### Available Inputs
**HDMI:** hdmi1, hdmi2, hdmi3, hdmi4  
**TV:** tv (Live TV)  
**Apps:** netflix, youtube, amazon, disney, apple, hbo, spotify, browser

## Requirements

For turning TV on:
- `wakeonlan` command (install with `brew install wakeonlan`)
- TV must have Wake-on-LAN enabled

For turning TV off and switching inputs:
- `curl` or `nc` (netcat) - usually pre-installed
- TV must be on and have LG Connect Apps enabled

## Integration with Other Modules

### Voice Control with ChatGPT
The ChatGPT Voice module can execute TV commands through voice:

```bash
# Say these commands to ChatGPT Voice:
"Turn on the TV"           # Executes ./tv_on.sh
"Switch to HDMI 2"         # Executes ./tv_input.sh hdmi2
"Open Netflix"             # Executes ./lgtv input netflix
"Turn off the television"  # Executes ./tv_off.sh
```

### Terminal Usage
Can be called from any script or terminal:

```bash
# From another directory
../LG/tv_on.sh
../LG/tv_input.sh hdmi1

# In automation scripts
#!/bin/bash
/path/to/travis/LG/tv_on.sh && sleep 5
/path/to/travis/LG/lgtv input netflix
```

### Programmatic Usage
```python
import subprocess

# Turn on TV
subprocess.run(["./LG/tv_on.sh"])

# Switch input
subprocess.run(["./LG/tv_input.sh", "hdmi2"])
```

## Troubleshooting

**TV won't turn on:**
- Check Wake-on-LAN is enabled in TV settings
- Ensure TV supports Wake-on-LAN over WiFi (some models only support it over Ethernet)

**TV won't turn off or switch inputs:**
- Ensure TV is on the same network
- Check LG Connect Apps is enabled
- Try running `./lgtv status` to verify connectivity

## Configuration

TV IP address is set to `10.0.0.75` in all scripts. If your TV IP changes, update the `TV_IP` variable in:
- `tv_on.sh`
- `tv_off.sh`
- `tv_input.sh`
- `lgtv`

## Additional Features

### Node.js Controllers
For advanced control, use the Node.js implementations:

```bash
# Setup
npm install

# Usage
node tv_control.js on
node tv_control.js off
node tv_control.js input hdmi1
node tv_simple.js
```

### Python Control (lgtv2)
Alternative Python-based control:

```bash
# Setup
./setup_lgtv2.sh

# Usage
lgtv scan              # Find TVs on network
lgtv auth 10.0.0.75    # Pair with TV
lgtv webos turnOff     # Turn off TV
```