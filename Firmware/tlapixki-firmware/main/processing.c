/*
       Processing Driver
*/
#include "processing.h"

#include "esp_log.h"
#include "modbus_data.h"
#include "tasks_common.h"

static const char *TAG = "Processing";

void processing_task(void *pvParameters) {
    extern QueueHandle_t ProcessingQueue;
    extern QueueHandle_t TransmissionQueue;
    MB_data_t received_modbus_data;
    transmitted_float_data_t modbus_float_data;

    for (;;)
        if (!xQueueReceive(ProcessingQueue, &received_modbus_data, pdMS_TO_TICKS(50))) {
            ESP_LOGE(TAG, "Error receiving value from Processing Queue!");
        } else {
            ESP_LOGI(TAG, "#%d with value %d received from Processing Queue", received_modbus_data.cid, received_modbus_data.value);

            // Procesamiento de acuerdo a CID

            switch (received_modbus_data.cid) {
                case 0:
                case 1:
                case 2:
                case 3:;
                    modbus_float_data.cid = received_modbus_data.cid;
                    modbus_float_data.value = received_modbus_data.value;
                    // Transmision
                    if (!xQueueSend(TransmissionQueue, &modbus_float_data, pdMS_TO_TICKS(5))) {
                        ESP_LOGE(TAG, "Error sending #%d with value %f to Transmission Queue!", modbus_float_data.cid, modbus_float_data.value);
                    } else {
                        ESP_LOGI(TAG, " #%d with value %f sent to Transmission Queue!", modbus_float_data.cid, modbus_float_data.value);
                    }
                    break;
                case 4:
                case 5:
                case 6:
                case 7:
                case 8:
                case 9:
                case 10:
                case 11:
                case 12:
                case 13:
                case 14:
                case 15:
                case 16:
                case 17:
                case 18:
                case 19:
                case 20:
                case 21:
                case 22:
                case 23:
                case 24:
                case 25:
                case 26:
                case 27:;
                    modbus_float_data.cid = received_modbus_data.cid;

                    if (received_modbus_data.value < 32768) {
                        modbus_float_data.value = (float)(received_modbus_data.value) / 10;
                    } else {
                        received_modbus_data.value = 65535 - received_modbus_data.value;
                        modbus_float_data.value = (float)(received_modbus_data.value) / 10;
                        modbus_float_data.value -= 1;
                    }
                    // Transmision
                    if (!xQueueSend(TransmissionQueue, &modbus_float_data, pdMS_TO_TICKS(5))) {
                        ESP_LOGE(TAG, "Error sending #%d with value %f to Transmission Queue!", modbus_float_data.cid, modbus_float_data.value);
                    } else {
                        ESP_LOGI(TAG, "#%d with value %f sent to Transmission Queue!", modbus_float_data.cid, modbus_float_data.value);
                    }
                    break;
                default:
                    break;
            }
            vTaskDelay(PROCESSING_TASK_BLOCK_TIME_MS / portTICK_PERIOD_MS);
        }
}
void processing_start(void) {
    ESP_LOGI(TAG, "STARTING Processing Application");

    // Start the HTTP application task
    xTaskCreatePinnedToCore(&processing_task, "processing_task", PROCESSING_TASK_STACK_SIZE, NULL, PROCESSING_TASK_PRIORITY, NULL, PROCESSING_TASK_CODE_ID);
}