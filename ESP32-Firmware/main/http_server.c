/*
    http_server.c

    Created on: Apr 26, 2022
    Author: Hugo Pérez

*/

#include "http_server.h"

#include "esp_err.h"
#include "esp_http_server.h"
#include "esp_log.h"
#include "tasks_common.h"
#include "wifi_app.h"

// Tag used for ESP serial console messages
static const char TAG[] = "http_server";

// HTTP server task handle
static httpd_handle_t http_server_handle = NULL;

// HTTP server monitor task handle
static TaskHandle_t task_http_server_monitor = NULL;

// Queue handle used to manipulate the main queue of events
static QueueHandle_t http_server_monitor_queue_handle;

// Embedded files: JQuery, index.html, app.css, app.js and favicon.ico files
extern const uint8_t jquery_3_3_1_min_js_start[] asm("_binary_jquery_3_3_1_min_js_start");
extern const uint8_t jquery_3_3_1_min_js_end[] asm("_binary_jquery_3_3_1_min_js_end");
extern const uint8_t index_html_start[] asm("_binary_index_html_start");
extern const uint8_t index_html_end[] asm("_binary_index_html_end");
extern const uint8_t app_css_start[] asm("_binary_app_css_start");
extern const uint8_t app_css_end[] asm("_binary_app_css_end");
extern const uint8_t app_js_start[] asm("_binary_app_js_start");
extern const uint8_t app_js_end[] asm("_binary_app_js_end");
extern const uint8_t favicon_ico_start[] asm("_binary_favicon_ico_start");
extern const uint8_t favicon_ico_end[] asm("_binary_favicon_ico_end");

/**
 * HTTP server monitor task used to track events of the HTTP server
 * @param pvParameters parameter which can be passed to the task.
 */
static void http_server_monitor(void *parameter) {
    http_server_queue_message_t msg;

    for (;;) {
        if (xQueueReceive(http_server_monitor_queue_handle, &msg, portMAX_DELAY)) {
            switch (msg.msgID) {
                case HTTP_MSG_WIFI_CONNECT_INIT:
                    ESP_LOGI(TAG, "HTTP_MSG_WIFI_CONNECT_INIT");

                    break;

                case HTTP_MSG_WIFI_CONNECT_SUCCESS:
                    ESP_LOGI(TAG, "HTTP_MSG_WIFI_CONNECT_SUCCESS");

                    break;

                case HTTP_MSG_WIFI_CONNECT_FAIL:
                    ESP_LOGI(TAG, "HTTP_MSG_WIFI_CONNECT_FAIL");

                    break;

                case HTTP_MSG_OTA_UPDATE_SUCCESSFUL:
                    ESP_LOGI(TAG, "HTTP_MSG_OTA_UPDATE_SUCCESSFUL");

                    break;

                case HTTP_MSG_OTA_UPDATE_FAILED:
                    ESP_LOGI(TAG, "HTTP_MSG_OTA_UPDATE_FAILED");

                    break;

                case HTTP_MSG_OTA_UPATE_INITIALIZED:
                    ESP_LOGI(TAG, "HTTP_MSG_OTA_UPATE_INITIALIZED");

                    break;

                default:
                    break;
            }
        }
    }
}

/**
 * Jquery get handler is requested when accessing the web page.
 * @param req HTTP request for which the uri needs to be handled.
 * @return ESP_OK
 */
static esp_err_t http_server_jquery_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "Jquery requested");

    httpd_resp_set_type(req, "application/javascript");
    httpd_resp_send(req, (const char *)jquery_3_3_1_min_js_start, jquery_3_3_1_min_js_end - jquery_3_3_1_min_js_start);

    return ESP_OK;
}

/**
 * Sends the index.html page.
 * @param req HTTP request for which the uri needs to be handled.
 * @return ESP_OK
 */
static esp_err_t http_server_index_html_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "index.html requested");

    httpd_resp_set_type(req, "text/html");
    httpd_resp_send(req, (const char *)index_html_start, index_html_end - index_html_start);

    return ESP_OK;
}

/**
 * app.css get handler is requested when accessing the web page.
 * @param req HTTP request for which the uri needs to be handled.
 * @return ESP_OK
 */
static esp_err_t http_server_app_css_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "app.css requested");

    httpd_resp_set_type(req, "text/css");
    httpd_resp_send(req, (const char *)app_css_start, app_css_end - app_css_start);

    return ESP_OK;
}

/**
 * app.js get handler is requested when accessing the web page.
 * @param req HTTP request for which the uri needs to be handled.
 * @return ESP_OK
 */
static esp_err_t http_server_app_js_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "app.js requested");

    httpd_resp_set_type(req, "application/javascript");
    httpd_resp_send(req, (const char *)app_js_start, app_js_end - app_js_start);

    return ESP_OK;
}

/**
 * Sends the .ico (icon) file when accessing the web page.
 * @param req HTTP request for which the uri needs to be handled.
 * @return ESP_OK
 */
static esp_err_t http_server_favicon_ico_handler(httpd_req_t *req) {
    ESP_LOGI(TAG, "favicon.ico requested");

    httpd_resp_set_type(req, "image/x-icon");
    httpd_resp_send(req, (const char *)favicon_ico_start, favicon_ico_end - favicon_ico_start);

    return ESP_OK;
}

/**
 * Sets up the default httpd server configuration.
 * @return http server instance handle if successful, NULL otherwise.
 */
static httpd_handle_t http_server_configure(void) {
    // Generate the default configuration
    httpd_config_t config = HTTPD_DEFAULT_CONFIG();

    // Create HTTP server monitor task
    xTaskCreatePinnedToCore(&http_server_monitor, "http_server_monitor", HTTP_SERVER_MONITOR_STACK_SIZE, NULL, HTTP_SERVER_MONITOR_PRIORITY, &task_http_server_monitor, HTTP_SERVER_MONITOR_CORE_ID);

    // Create the message queue
    http_server_monitor_queue_handle = xQueueCreate(3, sizeof(http_server_queue_message_t));

    // The core that the HTTP server will run on
    config.core_id = HTTP_SERVER_TASK_CORE_ID;

    // Adjust the default priority to 1 less than the wifi application task
    config.task_priority = HTTP_SERVER_TASK_PRIORITY;

    // Bump up the stack size (default is 4096)
    config.stack_size = HTTP_SERVER_TASK_STACK_SIZE;

    // Increase uri handlers
    config.max_uri_handlers = 20;

    // Increase the timeout limits
    config.recv_wait_timeout = 10;
    config.send_wait_timeout = 10;

    ESP_LOGI(TAG,
             "http_server_configure: Starting server on port: '%d' with task priority: '%d'",
             config.server_port,
             config.task_priority);

    // Start the httpd server
    if (httpd_start(&http_server_handle, &config) == ESP_OK) {
        ESP_LOGI(TAG, "http_server_configure: Registering URI handlers");

        // register query handler
        httpd_uri_t jquery_js = {
            .uri = "/jquery-3.3.1.min.js",
            .method = HTTP_GET,
            .handler = http_server_jquery_handler,
            .user_ctx = NULL};
        httpd_register_uri_handler(http_server_handle, &jquery_js);

        // register index.html handler
        httpd_uri_t index_html = {
            .uri = "/",
            .method = HTTP_GET,
            .handler = http_server_index_html_handler,
            .user_ctx = NULL};
        httpd_register_uri_handler(http_server_handle, &index_html);

        // register app.css handler
        httpd_uri_t app_css = {
            .uri = "/app.css",
            .method = HTTP_GET,
            .handler = http_server_app_css_handler,
            .user_ctx = NULL};
        httpd_register_uri_handler(http_server_handle, &app_css);

        // register app.js handler
        httpd_uri_t app_js = {
            .uri = "/app.js",
            .method = HTTP_GET,
            .handler = http_server_app_js_handler,
            .user_ctx = NULL};
        httpd_register_uri_handler(http_server_handle, &app_js);

        // register favicon.ico handler
        httpd_uri_t favicon_ico = {
            .uri = "/favicon.ico",
            .method = HTTP_GET,
            .handler = http_server_favicon_ico_handler,
            .user_ctx = NULL};
        httpd_register_uri_handler(http_server_handle, &favicon_ico);

        return http_server_handle;
    }

    return NULL;
}

void http_server_start(void) {
    if (http_server_handle == NULL) {
        http_server_handle = http_server_configure();
    }
}

void http_server_stop(void) {
    if (http_server_handle) {
        httpd_stop(http_server_handle);
        ESP_LOGI(TAG, "http_server_stop: stopping HTTP server");
        http_server_handle = NULL;
    }
    if (task_http_server_monitor) {
        vTaskDelete(task_http_server_monitor);
        ESP_LOGI(TAG, "http_server_stop: stopping HTTP server monitor");
        task_http_server_monitor = NULL;
    }
}

BaseType_t http_server_monitor_send_message(http_server_message_e msgID) {
    http_server_queue_message_t msg;
    msg.msgID = msgID;
    return xQueueSend(http_server_monitor_queue_handle, &msg, portMAX_DELAY);
}
