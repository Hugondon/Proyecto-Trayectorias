/*
       Modbus Master  Driver
*/
#ifndef MB_MASTER_H_
#define MB_MASTER_H_

#include <string.h>
#include <sys/queue.h>

#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_system.h"
#include "mbcontroller.h"

#define CONFIG_FMB_TCP_PORT_DEFAULT 502

#define MB_TCP_PORT (CONFIG_FMB_TCP_PORT_DEFAULT)  // TCP port used by example

// The number of parameters that intended to be used in the particular control process
#define MASTER_MAX_CIDS num_device_parameters

// Number of reading of parameters from slave
#define MASTER_MAX_RETRY (500)

// Timeout to update cid over Modbus
#define UPDATE_CIDS_TIMEOUT_MS (500)
#define UPDATE_CIDS_TIMEOUT_TICS (UPDATE_CIDS_TIMEOUT_MS / portTICK_RATE_MS)

// Timeout between polls
#define POLL_TIMEOUT_MS (1)
#define POLL_TIMEOUT_TICS (POLL_TIMEOUT_MS / portTICK_RATE_MS)
#define MB_MDNS_PORT (502)

// The macro to get offset for parameter in the appropriate structure
#define HOLD_OFFSET(field) ((uint16_t)(offsetof(holding_reg_params_t, field) + 1))
#define INPUT_OFFSET(field) ((uint16_t)(offsetof(input_reg_params_t, field) + 1))
#define COIL_OFFSET(field) ((uint16_t)(offsetof(coil_reg_params_t, field) + 1))
#define DISCR_OFFSET(field) ((uint16_t)(offsetof(discrete_reg_params_t, field) + 1))
#define STR(fieldname) ((const char*)(fieldname))

// Options can be used as bit masks or parameter limits
#define OPTS(min_val, max_val, step_val) \
    { .opt1 = min_val, .opt2 = max_val, .opt3 = step_val }

#define MB_ID_BYTE0(id) ((uint8_t)(id))
#define MB_ID_BYTE1(id) ((uint8_t)(((uint16_t)(id) >> 8) & 0xFF))
#define MB_ID_BYTE2(id) ((uint8_t)(((uint32_t)(id) >> 16) & 0xFF))
#define MB_ID_BYTE3(id) ((uint8_t)(((uint32_t)(id) >> 24) & 0xFF))

#define MB_ID2STR(id) MB_ID_BYTE0(id), MB_ID_BYTE1(id), MB_ID_BYTE2(id), MB_ID_BYTE3(id)

#if CONFIG_FMB_CONTROLLER_SLAVE_ID_SUPPORT
#define MB_DEVICE_ID (uint32_t) CONFIG_FMB_CONTROLLER_SLAVE_ID
#else
#define MB_DEVICE_ID (uint32_t)0x00112233
#endif

#define MB_MDNS_INSTANCE(pref) pref "mb_master_tcp"

// Enumeration of modbus device addresses accessed by master device
// Each address in the table is a index of TCP slave ip address in mb_communication_info_t::tcp_ip_addr table
enum {
    MB_DEVICE_ADDR1 = 5,  // UR5 Cobot
};

enum CIDs {
    CID_ROBOT_MODE = 0,
    CID_POWER_ON,
    CID_SECURITY_STOPPED,
    CID_EMERGENCY_STOPPED,
    CID_BASE_JOINT_ANGLE,
    CID_SHOULDER_JOINT_ANGLE,
    CID_ELBOW_JOINT_ANGLE,
    CID_WRIST_1_JOINT_ANGLE,
    CID_WRIST_2_JOINT_ANGLE,
    CID_WRIST_3_JOINT_ANGLE,
    CID_BASE_JOINT_ANGLE_VELOCITY,
    CID_SHOULDER_JOINT_ANGLE_VELOCITY,
    CID_ELBOW_JOINT_ANGLE_VELOCITY,
    CID_WRIST_1_JOINT_ANGLE_VELOCITY,
    CID_WRIST_2_JOINT_ANGLE_VELOCITY,
    CID_WRIST_3_JOINT_ANGLE_VELOCITY,
    CID_TCP_X_POSITION,
    CID_TCP_Y_POSITION,
    CID_TCP_Z_POSITION,
    CID_TCP_RX_ORIENTATION,
    CID_TCP_RY_ORIENTATION,
    CID_TCP_RZ_ORIENTATION,
    CID_TCP_X_SPEED,
    CID_TCP_Y_SPEED,
    CID_TCP_Z_SPEED,
    CID_TCP_RX_SPEED,
    CID_TCP_RY_SPEED,
    CID_TCP_RZ_SPEED,
    CID_COUNT
};

// This table represents slave IP addresses that correspond to the short address field of the slave in device_parameters structure
// Modbus TCP stack shall use these addresses to be able to connect and read parameters from slave
#define MB_SLAVE_COUNT 1

#pragma pack(push, 1)
typedef struct
{
    uint8_t discrete_input0 : 1;
    uint8_t discrete_input1 : 1;
    uint8_t discrete_input2 : 1;
    uint8_t discrete_input3 : 1;
    uint8_t discrete_input4 : 1;
    uint8_t discrete_input5 : 1;
    uint8_t discrete_input6 : 1;
    uint8_t discrete_input7 : 1;
    uint8_t discrete_input_port1 : 8;
} discrete_reg_params_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
    uint8_t coils_port0;
    uint8_t coils_port1;
} coil_reg_params_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
    float input_data0;   // 0
    float input_data1;   // 2
    float input_data2;   // 4
    float input_data3;   // 6
    uint16_t data[150];  // 8 + 150 = 158
    float input_data4;   // 158
    float input_data5;
    float input_data6;
    float input_data7;
} input_reg_params_t;
#pragma pack(pop)

#pragma pack(push, 1)
typedef struct
{
    float holding_data0;
    float holding_data1;
    float holding_data2;
    float holding_data3;
    uint16_t test_regs[150];
    float holding_data4;
    float holding_data5;
    float holding_data6;
    float holding_data7;
} holding_reg_params_t;
#pragma pack(pop)

esp_err_t master_init(mb_communication_info_t* comm_info);
void mb_communication_init(void);
void* master_get_param_data(const mb_parameter_descriptor_t* param_descriptor);
void master_operation_func(void* arg);
void mb_master_task(void* pvParameters);
void mb_master_start(void);

#endif