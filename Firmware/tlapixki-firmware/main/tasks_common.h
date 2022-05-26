/*
    tasks_common.h

    Created on: May 14th, 2022
    Author: Hugo Pérez

*/
#ifndef MAIN_TASKS_COMMON_H_
#define MAIN_TASKS_COMMON_H_

// Blink Task
#define BLINK_TASK_STACK_SIZE 1024
#define BLINK_TASK_PRIORITY 1
#define BLINK_TASK_CODE_ID 1
#define BLINK_TASK_BLOCK_TIME_MS 500

// HTTP Client Task
#define HTTP_CLIENT_TASK_STACK_SIZE 1024 * 10
#define HTTP_CLIENT_TASK_PRIORITY 7
#define HTTP_CLIENT_TASK_CODE_ID 0
#define HTTP_CLIENT_TASK_BLOCK_TIME_MS 1

// Modbus Master Task
#define MB_MASTER_TASK_STACK_SIZE 1024 * 4
#define MB_MASTER_TASK_PRIORITY 9
#define MB_MASTER_TASK_CODE_ID 0
#define MB_MASTER_TASK_CIDS_BLOCK_TIME_MS 500  // Timeout to update cid over Modbus
#define MB_MASTER_TASK_POLL_BLOCK_TIME_MS 10   // Timeout between polls

// status = xTaskCreate((void*)&modbus_tcp_master_task,
//                      "modbus_tcp_master_task",
//                      MB_CONTROLLER_STACK_SIZE, (4096)NULL,  // No parameters
//                      MB_CONTROLLER_PRIORITY(10 - 1),
//                      &mbm_opts->mbm_task_handle);

// Processing Task Task
#define PROCESSING_TASK_STACK_SIZE 1024 * 2
#define PROCESSING_TASK_PRIORITY 8
#define PROCESSING_TASK_CODE_ID 0
#define PROCESSING_TASK_BLOCK_TIME_MS 1

#endif /* MAIN_TASKS_COMMON_H_ */
