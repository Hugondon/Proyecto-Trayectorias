/*
        Ethernet - WiFi Connection Driver
*/
#ifndef ETH_WIFI_H_
#define ETH_WIFI_H_

#include <netdb.h>
#include <string.h>
#include <sys/socket.h>

#include "configurations.h"
#include "driver/gpio.h"
#include "esp_eth.h"
#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_wifi.h"
#include "esp_wifi_default.h"
#include "freertos/FreeRTOS.h"
#include "freertos/event_groups.h"
#include "freertos/task.h"
#include "lwip/err.h"
#include "lwip/sys.h"

// Defines WiFi
#define CONFIG_EXAMPLE_CONNECT_WIFI 1
// #define CONFIG_EXAMPLE_WIFI_SSID SSID
// #define CONFIG_EXAMPLE_WIFI_PASSWORD PASSWORD
#define CONFIG_EXAMPLE_WIFI_SCAN_METHOD_ALL_CHANNEL 1
#define CONFIG_EXAMPLE_WIFI_CONNECT_AP_BY_SIGNAL 1
#define CONFIG_EXAMPLE_WIFI_SCAN_RSSI_THRESHOLD -127

// Defines Ethernet
#define CONFIG_EXAMPLE_CONNECT_ETHERNET 1
#define CONFIG_EXAMPLE_USE_INTERNAL_ETHERNET 1
#define CONFIG_EXAMPLE_ETH_PHY_LAN87XX 1
#define CONFIG_EXAMPLE_ETH_PHY_ADDR 1
#define CONFIG_EXAMPLE_ETH_PHY_RST_GPIO 16
#define CONFIG_EXAMPLE_ETH_MDC_GPIO 23
#define CONFIG_EXAMPLE_ETH_MDIO_GPIO 18

// Defines Configurations
#define EXAMPLE_DO_CONNECT CONFIG_EXAMPLE_CONNECT_WIFI || CONFIG_EXAMPLE_CONNECT_ETHERNET
#define EXAMPLE_WIFI_SCAN_METHOD WIFI_ALL_CHANNEL_SCAN
#define EXAMPLE_WIFI_CONNECT_AP_SORT_METHOD WIFI_CONNECT_AP_BY_SIGNAL
#define EXAMPLE_WIFI_SCAN_AUTH_MODE_THRESHOLD WIFI_AUTH_OPEN

#define IP_ADDRESS ETHERNET_IF_IP_ADDRESS
#define GATEWAY ETHERNET_IF_GATEWAY
#define NETMASK ETHERNET_IF_NETMASK

// Prototypes

esp_netif_t *wifi_start(void);
void wifi_stop(void);
esp_netif_t *eth_start(void);
void eth_stop(void);

bool is_our_netif(const char *prefix, esp_netif_t *netif);
void start(void);
void stop(void);

void on_got_ip(void *arg, esp_event_base_t event_base, int32_t event_id, void *event_data);

esp_err_t example_connect(void);
esp_err_t example_disconnect(void);

void on_wifi_disconnect(void *arg, esp_event_base_t event_base,
                        int32_t event_id, void *event_data);

esp_netif_t *wifi_start(void);
void wifi_stop(void);

esp_netif_t *eth_start(void);
void eth_stop(void);

esp_netif_t *get_eth_netif(void);
esp_netif_t *get_example_netif(void);
esp_netif_t *get_example_netif_from_desc(const char *desc);

#endif