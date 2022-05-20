/*
        Project Network Configurations
*/
#ifndef CONFIGS_H_
#define CONFIGS_H_

// Ethernet
#define ETHERNET_IF_IP_ADDRESS  "192.168.1.104"
#define ETHERNET_IF_GATEWAY "192.168.1.101"
#define ETHERNET_IF_NETMASK "255.255.255.0"

// WiFi
#define SSID "Hugondon"
#define PASSWORD "hola1234"

// HTTP
// #define URL "http://198.54.116.58:80"
// #define URL "http://192.168.0.12:2020"
// #define URL "http://192.168.0.12:5000/send"
#define URL "http://172.20.10.2:5000/send"
// #define URL "http://10.48.154.16:5000/send"


// Modbus
#define MB_SLAVE_IP_ADDRESS "192.168.1.102" // Address corresponds to UR5
// #define MB_SLAVE_IP_ADDRESS "192.168.1.103"   // Address corresponds to Debug PC

#endif