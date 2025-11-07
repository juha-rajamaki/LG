#!/usr/bin/env node

// Wake-on-LAN implementation in Node.js
const dgram = require('dgram');
const { exec } = require('child_process');

const TV_IP = '10.0.0.75';
const TV_MAC = 'dc:03:98:18:49:1c'; // Known MAC address from ARP cache

// Function to get MAC address from ARP table
function getMacAddress(ip) {
    return new Promise((resolve, reject) => {
        // First ping to populate ARP cache
        exec(`ping -c 1 -W 2 ${ip}`, (error) => {
            // Ignore ping errors, just try to get MAC
            exec(`arp -n ${ip}`, (error, stdout) => {
                if (error) {
                    reject(new Error('Could not get MAC address from ARP table'));
                    return;
                }
                
                // Parse ARP output to extract MAC address
                const lines = stdout.split('\n');
                for (const line of lines) {
                    if (line.includes(ip)) {
                        const parts = line.split(/\s+/);
                        for (const part of parts) {
                            // Look for MAC address pattern (XX:XX:XX:XX:XX:XX)
                            if (/^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$/.test(part)) {
                                resolve(part);
                                return;
                            }
                        }
                    }
                }
                reject(new Error('MAC address not found in ARP table'));
            });
        });
    });
}

// Function to create Wake-on-LAN magic packet
function createMagicPacket(macAddress) {
    // Remove colons and convert to uppercase
    const cleanMac = macAddress.replace(/:/g, '').toUpperCase();
    
    // Validate MAC address
    if (cleanMac.length !== 12 || !/^[0-9A-F]{12}$/.test(cleanMac)) {
        throw new Error('Invalid MAC address format');
    }
    
    // Convert MAC to bytes
    const macBytes = [];
    for (let i = 0; i < 12; i += 2) {
        macBytes.push(parseInt(cleanMac.substr(i, 2), 16));
    }
    
    // Create magic packet: 6 bytes of 0xFF followed by 16 repetitions of MAC
    const packet = Buffer.alloc(102);
    
    // Fill first 6 bytes with 0xFF
    for (let i = 0; i < 6; i++) {
        packet[i] = 0xFF;
    }
    
    // Repeat MAC address 16 times
    for (let i = 0; i < 16; i++) {
        for (let j = 0; j < 6; j++) {
            packet[6 + i * 6 + j] = macBytes[j];
        }
    }
    
    return packet;
}

// Function to send Wake-on-LAN packet
function sendWakeOnLan(macAddress, broadcastAddress = '255.255.255.255') {
    return new Promise((resolve, reject) => {
        try {
            const packet = createMagicPacket(macAddress);
            const client = dgram.createSocket('udp4');
            
            client.bind(() => {
                client.setBroadcast(true);
                
                // Send to multiple ports commonly used for WOL
                const ports = [7, 9]; // Port 0 is invalid, removed
                let sent = 0;
                
                ports.forEach(port => {
                    client.send(packet, port, broadcastAddress, (error) => {
                        sent++;
                        if (error) {
                            console.log(`Warning: Failed to send to port ${port}: ${error.message}`);
                        }
                        
                        if (sent === ports.length) {
                            client.close();
                            resolve();
                        }
                    });
                });
            });
            
        } catch (error) {
            reject(error);
        }
    });
}

// Main function
async function main() {
    console.log('Wake-on-LAN for LG TV');
    console.log(`Target IP: ${TV_IP}`);
    
    try {
        let macAddress = TV_MAC;
        
        // Try to get MAC from ARP table first, fallback to known MAC
        try {
            console.log('Getting MAC address from ARP table...');
            macAddress = await getMacAddress(TV_IP);
            console.log(`MAC Address from ARP: ${macAddress}`);
        } catch (error) {
            console.log(`Using known MAC address: ${TV_MAC}`);
        }
        
        console.log('Sending Wake-on-LAN packets...');
        await sendWakeOnLan(macAddress);
        
        console.log('Wake-on-LAN packets sent successfully!');
        console.log('The TV should turn on within a few seconds.');
        console.log('');
        console.log('Note: Wake-on-LAN must be enabled on your TV:');
        console.log('  Settings > General > Network > Wake-on-LAN');
        
    } catch (error) {
        console.error('Error:', error.message);
        console.log('');
        console.log('Troubleshooting:');
        console.log('1. Make sure the TV was on recently so its MAC is in ARP cache');
        console.log('2. Enable Wake-on-LAN in TV settings');
        console.log('3. Some TVs only support WOL over Ethernet, not WiFi');
        console.log('4. Try: arp -a | grep 10.0.0.75  # to see if MAC is available');
        process.exit(1);
    }
}

main();