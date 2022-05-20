#ifndef MODBUS_DATA_H_
#define MODBUS_DATA_H_

#include <stdint.h>

#include "freertos/FreeRTOS.h"
#include "freertos/queue.h"

#define AMOUNT_OF_MB_READ_DATA 28

// Structure
typedef struct MB_data {
    uint16_t cid;
    uint16_t value;
} MB_data_t;

extern QueueHandle_t ProcessingQueue, TransmissionQueue;

#endif