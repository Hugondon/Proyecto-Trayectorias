/*
       HTTP Requests Driver
*/
#ifndef HTTP_REQUESTS_H_
#define HTTP_REQUESTS_H_

#include "esp_log.h"
#include "esp_http_client.h"

esp_err_t client_event_handler(esp_http_client_event_t *evt);
void http_client_get(void);
void http_client_task(void *pvParameters);
void http_client_start(void);

#endif
