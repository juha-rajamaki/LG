#!/usr/bin/env node

// Simple LG TV Control using WebSocket
const WebSocket = require('ws');
const fs = require('fs');
const path = require('path');

const TV_IP = '10.0.0.61';
const TV_PORT = 3000;
const action = process.argv[2];

// Key file to store pairing information
const keyFile = path.join(process.env.HOME, `.lgtv_${TV_IP.replace(/\./g, '_')}.key`);

if (!action) {
    console.log('Usage: node tv_simple.js <action>');
    console.log('Actions:');
    console.log('  pair    - Pair with TV (one-time setup)');
    console.log('  off     - Turn TV off');
    console.log('  info    - Get TV info');
    process.exit(1);
}

let clientKey = '';

// Load existing key if available
try {
    if (fs.existsSync(keyFile)) {
        clientKey = fs.readFileSync(keyFile, 'utf8').trim();
        console.log('Using saved pairing key');
    }
} catch (err) {
    console.log('No existing pairing key found');
}

const ws = new WebSocket(`ws://${TV_IP}:${TV_PORT}`);

ws.on('open', () => {
    console.log('Connected to TV');
    
    if (action === 'pair') {
        // Send pairing request
        const pairMessage = {
            "type": "register",
            "id": "register_0",
            "payload": {
                "forcePairing": false,
                "pairingType": "PROMPT",
                "client-key": clientKey,
                "manifest": {
                    "manifestVersion": 1,
                    "appVersion": "1.0.0",
                    "signed": {
                        "created": "20140509",
                        "appId": "com.lge.test",
                        "vendorId": "com.lge",
                        "localizedAppNames": {
                            "": "LG Remote App",
                            "ko-KR": "리모컨 앱",
                            "zxx-XX": "ЛГ Rэмotэ AПП"
                        },
                        "localizedVendorNames": {
                            "": "LG Electronics"
                        },
                        "permissions": [
                            "TEST_SECURE",
                            "CONTROL_INPUT_TEXT",
                            "CONTROL_MOUSE_AND_KEYBOARD",
                            "READ_INSTALLED_APPS",
                            "READ_LGE_SDX",
                            "READ_NOTIFICATIONS",
                            "SEARCH",
                            "WRITE_SETTINGS",
                            "WRITE_NOTIFICATIONS",
                            "CONTROL_POWER",
                            "READ_CURRENT_CHANNEL",
                            "READ_RUNNING_APPS"
                        ],
                        "serial": "2f930e2d2cfe083771f68e4fe7bb07"
                    },
                    "permissions": [
                        "LAUNCH",
                        "LAUNCH_WEBAPP",
                        "APP_TO_APP",
                        "CLOSE",
                        "TEST_OPEN",
                        "TEST_PROTECTED",
                        "CONTROL_AUDIO",
                        "CONTROL_DISPLAY",
                        "CONTROL_INPUT_JOYSTICK",
                        "CONTROL_INPUT_MEDIA_RECORDING",
                        "CONTROL_INPUT_MEDIA_PLAYBACK",
                        "CONTROL_INPUT_TV",
                        "CONTROL_POWER",
                        "READ_APP_STATUS",
                        "READ_CURRENT_CHANNEL",
                        "READ_INPUT_DEVICE_LIST",
                        "READ_NETWORK_STATE",
                        "READ_RUNNING_APPS",
                        "READ_TV_CHANNEL_LIST",
                        "WRITE_NOTIFICATION_TOAST",
                        "READ_POWER_STATE",
                        "READ_COUNTRY_INFO"
                    ]
                }
            }
        };
        
        console.log('Sending pairing request...');
        console.log('Please accept the connection on your TV screen');
        ws.send(JSON.stringify(pairMessage));
        
    } else if (clientKey) {
        // Use existing key to connect
        const registerMessage = {
            "type": "register",
            "id": "register_0",
            "payload": {
                "client-key": clientKey
            }
        };
        
        ws.send(JSON.stringify(registerMessage));
    } else {
        console.log('No pairing key found. Please run: node tv_simple.js pair');
        ws.close();
        process.exit(1);
    }
});

ws.on('message', (data) => {
    try {
        const message = JSON.parse(data);
        console.log('Received:', message.type);
        
        if (message.type === 'registered') {
            if (message.payload && message.payload['client-key']) {
                // Save the client key
                const newKey = message.payload['client-key'];
                fs.writeFileSync(keyFile, newKey);
                console.log('Pairing successful! Key saved for future use.');
                clientKey = newKey;
            }
            
            // Now execute the requested action
            if (action === 'off') {
                console.log('Sending power off command...');
                const powerOffMessage = {
                    "type": "request",
                    "id": "power_off_1",
                    "uri": "ssap://system/turnOff"
                };
                ws.send(JSON.stringify(powerOffMessage));
                
            } else if (action === 'info') {
                console.log('Getting TV info...');
                const infoMessage = {
                    "type": "request",
                    "id": "info_1", 
                    "uri": "ssap://system/getSystemInfo"
                };
                ws.send(JSON.stringify(infoMessage));
            }
            
        } else if (message.type === 'response') {
            if (message.id === 'power_off_1') {
                console.log('TV turned off successfully!');
                ws.close();
            } else if (message.id === 'info_1') {
                console.log('TV Info:', JSON.stringify(message.payload, null, 2));
                ws.close();
            }
        } else if (message.type === 'error') {
            console.error('TV Error:', message.error);
            ws.close();
        }
        
    } catch (err) {
        console.error('Error parsing message:', err.message);
    }
});

ws.on('error', (err) => {
    console.error('WebSocket error:', err.message);
    process.exit(1);
});

ws.on('close', () => {
    console.log('Connection closed');
    process.exit(0);
});

// Timeout after 30 seconds for pairing, 10 seconds for other operations
const timeout = action === 'pair' ? 30000 : 10000;
setTimeout(() => {
    console.log('Operation timeout');
    ws.close();
    process.exit(1);
}, timeout);