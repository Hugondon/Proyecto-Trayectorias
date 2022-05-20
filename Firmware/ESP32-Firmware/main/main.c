#include <stdio.h>

/*
    Application entry point.
*/
#include "DHT22.h"
#include "nvs_flash.h"
#include "wifi_app.h"

void app_main(void) {
    // Initialize NVS
    esp_err_t ret = nvs_flash_init();
    if (ret == ESP_ERR_NVS_NO_FREE_PAGES || ret == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        ret = nvs_flash_init();
    }
    ESP_ERROR_CHECK(ret);

    // Start Wifi
    wifi_app_start();
    // Start DHT22 Sensor task
    // DHT22_task_start();

    // for (;;) {
    //     rgb_led_wifi_app_started();
    //     vTaskDelay(300 / portTICK_PERIOD_MS);
    //     rgb_led_http_server_started();
    //     vTaskDelay(300 / portTICK_PERIOD_MS);
    //     rgb_led_wifi_connected();
    //     vTaskDelay(300 / portTICK_PERIOD_MS);
    // }
}
