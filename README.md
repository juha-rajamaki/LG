# LG TV Control Scripts

Control your LG 65NANO81 TV from the terminal.

## Setup

1. Ensure your TV and computer are on the same network
2. Enable Wake-on-LAN on your TV:
   - Settings > General > Network > Wake-on-LAN > On
3. Enable LG Connect Apps:
   - Settings > General > Network > LG Connect Apps > On

## Usage

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

## Troubleshooting

**TV won't turn on:**
- Check Wake-on-LAN is enabled in TV settings
- Ensure TV supports Wake-on-LAN over WiFi (some models only support it over Ethernet)

**TV won't turn off or switch inputs:**
- Ensure TV is on the same network
- Check LG Connect Apps is enabled
- Try running `./lgtv status` to verify connectivity

## Configuration

TV IP address is set to `10.0.0.61` in all scripts. If your TV IP changes, update the `TV_IP` variable in:
- `tv_on.sh`
- `tv_off.sh`
- `tv_input.sh`
- `lgtv`