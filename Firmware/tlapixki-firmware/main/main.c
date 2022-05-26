/*
    Tlapixki - Firmware v 1.0
    Authors: Hugo Pérez (https://github.com/Hugondon)

    Based on ESP-IDF Examples

    HARA Services
*/
#include <string.h>

#include "configurations.h"
#include "driver/gpio.h"
#include "esp_http_client.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "ethernet-wifi-connect.h"
#include "modbus_data.h"
#include "modbus_master.h"
#include "nvs_flash.h"
#include "processing.h"
#include "requests.h"
#include "tasks_common.h"

// TCP client multiple netif
static const char *TAG = "main";

esp_err_t init_leds(void) {
    gpio_reset_pin(LED_WHITE_GPIO);
    gpio_set_direction(LED_WHITE_GPIO, GPIO_MODE_OUTPUT);
    gpio_reset_pin(LED_GREEN_GPIO);
    gpio_set_direction(LED_GREEN_GPIO, GPIO_MODE_OUTPUT);
    gpio_reset_pin(LED_BLUE_GPIO);
    gpio_set_direction(LED_BLUE_GPIO, GPIO_MODE_OUTPUT);
    return ESP_OK;
}

void vTaskBlink(void *param) {
    uint8_t white_led_level = 0;

    while (1) {
        white_led_level = !white_led_level;
        gpio_set_level(LED_WHITE_GPIO, white_led_level);
        vTaskDelay(BLINK_TASK_BLOCK_TIME_MS / portTICK_PERIOD_MS);
    }
}

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

    init_leds();

    // gpio_set_level(LED_WHITE_GPIO, 1);
    // gpio_set_level(LED_GREEN_GPIO, 1);
    // gpio_set_level(LED_BLUE_GPIO, 1);

    xTaskCreatePinnedToCore(&vTaskBlink, "Blink Task", BLINK_TASK_STACK_SIZE, NULL, BLINK_TASK_PRIORITY, NULL, BLINK_TASK_CODE_ID);

    processing_start();
    http_client_start();
    mb_master_start();
}
