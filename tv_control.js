#!/usr/bin/env node

// LG TV Control using lgtv2 module
const LGTV = require('lgtv2');
const fs = require('fs');
const path = require('path');

// Load TV IP from .env file
let TV_IP = '10.0.0.75'; // Default fallback
try {
    const envPath = path.join(__dirname, '..', '.env');
    if (fs.existsSync(envPath)) {
        const envContent = fs.readFileSync(envPath, 'utf8');
        const tvIpMatch = envContent.match(/^TV_IP=(.+)$/m);
        if (tvIpMatch) {
            TV_IP = tvIpMatch[1].trim();
        }
    }
} catch (error) {
    // Use fallback IP
}
const action = process.argv[2];
const parameter = process.argv[3];

if (!action) {
    console.log('Usage: node tv_control.js <action> [parameter]');
    console.log('Actions:');
    console.log('  connect    - Pair with TV (one-time setup)');
    console.log('  off        - Turn TV off');
    console.log('  input <id> - Switch input (HDMI_1, HDMI_2, etc.)');
    console.log('  app <name> - Launch app (netflix, youtube, etc.)');
    console.log('  volume <n> - Set volume (0-100)');
    console.log('  mute       - Toggle mute');
    process.exit(1);
}

const lgtv = new LGTV({
    url: `ws://${TV_IP}:3000`,
    keyFile: `${process.env.HOME}/.lgtv2_${TV_IP.replace(/\./g, '_')}.key`
});

lgtv.on('error', (err) => {
    console.error('Error:', err.message);
    process.exit(1);
});

lgtv.on('connecting', () => {
    console.log('Connecting to TV...');
});

lgtv.on('connected', () => {
    console.log('Connected to TV');
    
    switch (action) {
        case 'connect':
            console.log('Pairing with TV...');
            console.log('Please accept the connection request on your TV screen');
            // Keep connection open for pairing
            setTimeout(() => {
                console.log('Pairing completed! Key saved for future use.');
                lgtv.disconnect();
            }, 10000);
            break;
            
        case 'off':
            console.log('Turning TV off...');
            lgtv.request('ssap://system/turnOff', (err, res) => {
                if (err) {
                    console.error('Failed to turn off TV:', err.message);
                } else {
                    console.log('TV turned off successfully!');
                }
                lgtv.disconnect();
            });
            break;
            
        case 'input':
            if (!parameter) {
                console.error('Please specify input (HDMI_1, HDMI_2, HDMI_3, HDMI_4)');
                process.exit(1);
            }
            console.log(`Switching to input: ${parameter}`);
            lgtv.request('ssap://tv/switchInput', {inputId: parameter}, (err, res) => {
                if (err) {
                    console.error('Failed to switch input:', err.message);
                } else {
                    console.log(`Switched to ${parameter} successfully!`);
                }
                lgtv.disconnect();
            });
            break;
            
        case 'app':
            if (!parameter) {
                console.error('Please specify app name');
                process.exit(1);
            }
            
            // Map common app names to their IDs
            const apps = {
                'netflix': 'netflix',
                'youtube': 'youtube.leanback.v4',
                'amazon': 'amazon',
                'disney': 'com.disney.disneyplus-prod',
                'hbo': 'com.hbo.hbomax',
                'spotify': 'spotify-beehive',
                'browser': 'com.webos.app.browser'
            };
            
            const appId = apps[parameter.toLowerCase()] || parameter;
            console.log(`Launching app: ${parameter}`);
            
            lgtv.request('ssap://system.launcher/launch', {id: appId}, (err, res) => {
                if (err) {
                    console.error('Failed to launch app:', err.message);
                } else {
                    console.log(`Launched ${parameter} successfully!`);
                }
                lgtv.disconnect();
            });
            break;
            
        case 'volume':
            if (!parameter || isNaN(parameter)) {
                console.error('Please specify volume level (0-100)');
                process.exit(1);
            }
            console.log(`Setting volume to: ${parameter}`);
            lgtv.request('ssap://audio/setVolume', {volume: parseInt(parameter)}, (err, res) => {
                if (err) {
                    console.error('Failed to set volume:', err.message);
                } else {
                    console.log(`Volume set to ${parameter}!`);
                }
                lgtv.disconnect();
            });
            break;
            
        case 'mute':
            console.log('Toggling mute...');
            lgtv.request('ssap://audio/setMute', {mute: true}, (err, res) => {
                if (err) {
                    console.error('Failed to mute:', err.message);
                } else {
                    console.log('TV muted!');
                }
                lgtv.disconnect();
            });
            break;
            
        default:
            console.error('Unknown action:', action);
            process.exit(1);
    }
});

// Set a timeout for connection
setTimeout(() => {
    console.error('Connection timeout. Make sure TV is on and reachable.');
    process.exit(1);
}, 10000);

// Connect to TV
lgtv.connect();