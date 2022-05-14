/*
       HTTP Requests Driver

*/

#include "requests.h"

#include "tasks_common.h"

static const char *TAG = "HTTP_CLIENT";
esp_err_t client_event_handler(esp_http_client_event_t *evt) {
    switch (evt->event_id) {
        case HTTP_EVENT_ERROR:
            ESP_LOGD(TAG, "HTTP_EVENT_ERROR");
            break;
        case HTTP_EVENT_ON_CONNECTED:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_CONNECTED");
            break;
        case HTTP_EVENT_HEADER_SENT:
            ESP_LOGD(TAG, "HTTP_EVENT_HEADER_SENT");
            break;
        case HTTP_EVENT_ON_HEADER:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
            printf("Data: %.*s\n", evt->data_len, (char *)evt->data);
            break;
        case HTTP_EVENT_ON_FINISH:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_FINISH");
            break;
        case HTTP_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "HTTP_EVENT_DISCONNECTED");
            break;
        default:
            break;
    }
    return ESP_OK;
}
void http_client_get(void) {
    esp_http_client_config_t client_configuration = {
        .url = "http://worldclockapi.com/api/json/est/now",
        .event_handler = client_event_handler};

    esp_http_client_handle_t client = esp_http_client_init(&client_configuration);

    ESP_LOGI(TAG, "Get Request!");
    esp_http_client_perform(client);
    esp_http_client_cleanup(client);
}
void http_client_task(void *pvParameters) {
    esp_http_client_config_t client_configuration = {
        .url = "http://worldclockapi.com/api/json/utc/now",
        .event_handler = client_event_handler};

    esp_http_client_handle_t client = esp_http_client_init(&client_configuration);
    for (;;) {
        ESP_LOGI(TAG, "Get Request!");
        esp_http_client_perform(client);
        esp_http_client_cleanup(client);
    }
    vTaskDelay(5000 / portTICK_PERIOD_MS);
}
void http_client_start(void) {
    ESP_LOGI(TAG, "STARTING HTTP Client Application");

    // Start the WiFi application task
    xTaskCreatePinnedToCore(&http_client_task, "http_client_task", HTTP_CLIENT_TASK_STACK_SIZE, NULL, HTTP_CLIENT_TASK_PRIORITY, NULL, HTTP_CLIENT_TASK_CODE_ID);
}
