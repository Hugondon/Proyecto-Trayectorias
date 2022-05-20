/*
       Processing Driver
*/

#ifndef PROCESSING_H_
#define PROCESSING_H_

#include <stdint.h>

// Structure
typedef struct transmitted_data {
    uint16_t cid;
    float value; 
} transmitted_float_data_t;

  void processing_task(void *pvParameters);

  void processing_start(void);

#endif
