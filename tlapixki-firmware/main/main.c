/*
    Tlapixki - Firmware v 0.1
    Authors: Hugo Pérez (https://github.com/Hugondon)

    Based on ESP-IDF Examples

    HARA Services
*/
#include <string.h>

#include "esp_http_client.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "ethernet-wifi-connect.h"
#include "modbus_data.h"
#include "modbus_master.h"
#include "nvs_flash.h"
#include "processing.h"
#include "requests.h"

// TCP client multiple netif
static const char *TAG = "main";

void app_main(void) {
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // 1. Wi-Fi / Lightweight IP Init Phase
    esp_netif_init();                                  // TCP/IP Initiation
    ESP_ERROR_CHECK(esp_event_loop_create_default());  // Event Loop
    ESP_ERROR_CHECK(example_connect());

    extern QueueHandle_t ProcessingQueue;
    extern QueueHandle_t TransmissionQueue;

    ProcessingQueue = xQueueCreate(AMOUNT_OF_MB_READ_DATA * 4, sizeof(MB_data_t));
    TransmissionQueue = xQueueCreate(AMOUNT_OF_MB_READ_DATA * 4, sizeof(transmitted_float_data_t));

    processing_start();
    http_client_start();
    mb_master_start();
}
