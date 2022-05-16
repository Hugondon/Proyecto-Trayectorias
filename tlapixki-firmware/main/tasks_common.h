/*
    tasks_common.h

    Created on: May 14th, 2022
    Author: Hugo Pérez

*/
#ifndef MAIN_TASKS_COMMON_H_
#define MAIN_TASKS_COMMON_H_

// HTTP Client Task
#define HTTP_CLIENT_TASK_STACK_SIZE 1024 * 10
#define HTTP_CLIENT_TASK_PRIORITY 5
#define HTTP_CLIENT_TASK_CODE_ID 0

// Modbus Master Task
#define MB_MASTER_TASK_STACK_SIZE 4096
#define MB_MASTER_TASK_PRIORITY 1
#define MB_MASTER_TASK_CODE_ID 0
// status = xTaskCreate((void*)&modbus_tcp_master_task,
//                      "modbus_tcp_master_task",
//                      MB_CONTROLLER_STACK_SIZE, (4096)NULL,  // No parameters
//                      MB_CONTROLLER_PRIORITY(10 - 1),
//                      &mbm_opts->mbm_task_handle);

#endif /* MAIN_TASKS_COMMON_H_ */
