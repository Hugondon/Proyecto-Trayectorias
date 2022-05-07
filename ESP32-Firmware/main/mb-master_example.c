/*
 * SPDX-FileCopyrightText: 2016-2022 Espressif Systems (Shanghai) CO LTD
 *
 * SPDX-License-Identifier: Apache-2.0
 */

// FreeModbus Master Example ESP32

#include <string.h>
#include <sys/queue.h>

#include "esp_event.h"
#include "esp_log.h"
#include "esp_netif.h"
#include "esp_system.h"
#include "esp_wifi.h"
#include "mbcontroller.h"
#include "mdns.h"
#include "modbus_params.h"  // for modbus parameters structures
#include "nvs_flash.h"
#include "protocol_examples_common.h"
#include "sdkconfig.h"

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
static const char* TAG = "MASTER_TEST";

// Enumeration of modbus device addresses accessed by master device
// Each address in the table is a index of TCP slave ip address in mb_communication_info_t::tcp_ip_addr table
enum {
    MB_DEVICE_ADDR1 = 5,  // UR5 Cobot
};

// // Example Data (Object) Dictionary for Modbus parameters:
// // The CID field in the table must be unique.
// // Modbus Slave Addr field defines slave address of the device with correspond parameter.
// // Modbus Reg Type - Type of Modbus register area (Holding register, Input Register and such).
// // Reg Start field defines the start Modbus register number and Reg Size defines the number of registers for the characteristic accordingly.
// // The Instance Offset defines offset in the appropriate parameter structure that will be used as instance to save parameter value.
// // Data Type, Data Size specify type of the characteristic and its data size.
// // Parameter Options field specifies the options that can be used to process parameter value (limits or masks).
// // Access Mode - can be used to implement custom options for processing of characteristic (Read/Write restrictions, factory mode values and etc).

// const mb_parameter_descriptor_t device_parameters[] = {
//     // { CID, Param Name, Units, Modbus Slave Addr, Modbus Reg Type, Reg Start, Reg Size, Instance Offset, Data Type, Data Size, Parameter Options, Access Mode}
//     {CID_ROBOT_MODE, STR("Robot Mode"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 258, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_POWER_ON, STR("isPowerOnRobot"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 260, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_SECURITY_STOPPED, STR("isSecurityStopped"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 261, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_EMERGENCY_STOPPED, STR("isEmergencyStopped"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 262, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_BASE_JOINT_ANGLE, STR("Base Joint Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 270, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_SHOULDER_JOINT_ANGLE, STR("Shoulder Joint Angle "), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 271, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_ELBOW_JOINT_ANGLE, STR("Elbow Joint Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 272, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_1_JOINT_ANGLE, STR("Wrist 1 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 273, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_2_JOINT_ANGLE, STR("Wrist 2 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 274, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_3_JOINT_ANGLE, STR("Wrist 3 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 275, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_BASE_JOINT_ANGLE_VELOCITY, STR("Base Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 280, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_SHOULDER_JOINT_ANGLE_VELOCITY, STR("Shoulder Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 281, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_ELBOW_JOINT_ANGLE_VELOCITY, STR("Elbow Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 282, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_1_JOINT_ANGLE_VELOCITY, STR("Wrist 1 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 283, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_2_JOINT_ANGLE_VELOCITY, STR("Wrist 2 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 284, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_WRIST_3_JOINT_ANGLE_VELOCITY, STR("Wrist 3 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 285, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_X_POSITION, STR("TCP X Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 400, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_Y_POSITION, STR("TCP Y Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 401, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_Z_POSITION, STR("TCP Z Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 402, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RX_ORIENTATION, STR("TCP RX Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 403, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RY_ORIENTATION, STR("TCP RY Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 404, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RZ_ORIENTATION, STR("TCP RZ Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 405, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_X_SPEED, STR("TCP X Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 410, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_Y_SPEED, STR("TCP X Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 411, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_Z_SPEED, STR("TCP X Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 412, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RX_SPEED, STR("TCP RX Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 413, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RY_SPEED, STR("TCP RY Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 414, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_TCP_RZ_SPEED, STR("TCP RZ Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 415, 2, 0, PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},

// };
// Enumeration of all supported CIDs for device (used in parameter definition table)
// enum {
//     CID_HOLD_DATA_0 = 0,
//     CID_HOLD_DATA_1,
//     CID_HOLD_DATA_2,
//     CID_HOLD_DATA_3,
//     CID_COUNT
// };

// Example Data (Object) Dictionary for Modbus parameters:
// The CID field in the table must be unique.
// Modbus Slave Addr field defines slave address of the device with correspond parameter.
// Modbus Reg Type - Type of Modbus register area (Holding register, Input Register and such).
// Reg Start field defines the start Modbus register number and Reg Size defines the number of registers for the characteristic accordingly.
// The Instance Offset defines offset in the appropriate parameter structure that will be used as instance to save parameter value.
// Data Type, Data Size specify type of the characteristic and its data size.
// Parameter Options field specifies the options that can be used to process parameter value (limits or masks).
// Access Mode - can be used to implement custom options for processing of characteristic (Read/Write restrictions, factory mode values and etc).
// const mb_parameter_descriptor_t device_parameters[] = {
//     // { CID, Param Name, Units, Modbus Slave Addr, Modbus Reg Type, Reg Start, Reg Size, Instance Offset, Data Type, Data Size, Parameter Options, Access Mode}
//     {CID_HOLD_DATA_0, STR("Humidity_1"), STR("%rH"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 0, 2, HOLD_OFFSET(holding_data0), PARAM_TYPE_FLOAT, 4, OPTS(0, 100, 1), PAR_PERMS_READ},
//     {CID_HOLD_DATA_1, STR("Humidity_2"), STR("%rH"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 2, 2, HOLD_OFFSET(holding_data1), PARAM_TYPE_FLOAT, 4, OPTS(0, 100, 1), PAR_PERMS_READ},
//     {CID_HOLD_DATA_2, STR("Humidity_3"), STR("%rH"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 4, 2, HOLD_OFFSET(holding_data2), PARAM_TYPE_FLOAT, 4, OPTS(0, 100, 1), PAR_PERMS_READ},
//     {3, STR("Hola"), STR("Units"), 5, MB_PARAM_HOLDING, 4, 2, HOLD_OFFSET(holding_data2), PARAM_TYPE_U16, 4, OPTS(0, 100, 1), PAR_PERMS_READ},
// };

// const mb_parameter_descriptor_t device_parameters[] = {
//     // {CID,                Param Name,  Units,        Modbus Slave Addr,   Modbus Reg Type,    Reg Start,  Reg Size,   Instance Offset,            Data Type,      Data Size, Parameter Options,   Access Mode}
//     // {CID_HOLD_DATA_0,    STR("Hofla"), STR("Units"), 5,                   MB_PARAM_HOLDING,   0,         2,          HOLD_OFFSET(holding_data0), PARAM_TYPE_U16, 4,          OPTS(0, 100, 1),    PAR_PERMS_READ},
//     {CID_ROBOT_MODE, STR("Robot Mode"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 258, 2, HOLD_OFFSET(test_regs[0]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
//     {CID_POWER_ON, STR("isPowerOnRobot"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 260, 2, HOLD_OFFSET(test_regs[1]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
// };
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

const mb_parameter_descriptor_t device_parameters[] = {
    // { CID, Param Name, Units, Modbus Slave Addr, Modbus Reg Type, Reg Start, Reg Size, Instance Offset, Data Type, Data Size, Parameter Options, Access Mode}
    {CID_ROBOT_MODE, STR("Robot Mode"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 258, 1, HOLD_OFFSET(test_regs[0]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_POWER_ON, STR("isPowerOnRobot"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 260, 2, HOLD_OFFSET(test_regs[1]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_SECURITY_STOPPED, STR("isSecurityStopped"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 261, 2, HOLD_OFFSET(test_regs[2]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_EMERGENCY_STOPPED, STR("isEmergencyStopped"), STR("on/off"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 262, 2, HOLD_OFFSET(test_regs[3]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_BASE_JOINT_ANGLE, STR("Base Joint Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 270, 2, HOLD_OFFSET(test_regs[4]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_SHOULDER_JOINT_ANGLE, STR("Shoulder Joint Angle "), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 271, 2, HOLD_OFFSET(test_regs[5]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_ELBOW_JOINT_ANGLE, STR("Elbow Joint Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 272, 2, HOLD_OFFSET(test_regs[6]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_1_JOINT_ANGLE, STR("Wrist 1 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 273, 2, HOLD_OFFSET(test_regs[7]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_2_JOINT_ANGLE, STR("Wrist 2 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 274, 2, HOLD_OFFSET(test_regs[8]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_3_JOINT_ANGLE, STR("Wrist 3 Angle"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 275, 1, HOLD_OFFSET(test_regs[9]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_BASE_JOINT_ANGLE_VELOCITY, STR("Base Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 280, 2, HOLD_OFFSET(test_regs[10]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_SHOULDER_JOINT_ANGLE_VELOCITY, STR("Shoulder Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 281, 2, HOLD_OFFSET(test_regs[11]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_ELBOW_JOINT_ANGLE_VELOCITY, STR("Elbow Joint Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 282, 2, HOLD_OFFSET(test_regs[12]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_1_JOINT_ANGLE_VELOCITY, STR("Wrist 1 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 283, 2, HOLD_OFFSET(test_regs[13]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_2_JOINT_ANGLE_VELOCITY, STR("Wrist 2 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 284, 2, HOLD_OFFSET(test_regs[14]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_WRIST_3_JOINT_ANGLE_VELOCITY, STR("Wrist 3 Angle Velocity"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 285, 1, HOLD_OFFSET(test_regs[15]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_X_POSITION, STR("TCP X Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 400, 2, HOLD_OFFSET(test_regs[16]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_Y_POSITION, STR("TCP Y Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 401, 2, HOLD_OFFSET(test_regs[17]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_Z_POSITION, STR("TCP Z Position"), STR("tenth of mm"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 402, 2, HOLD_OFFSET(test_regs[18]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RX_ORIENTATION, STR("TCP RX Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 403, 2, HOLD_OFFSET(test_regs[19]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RY_ORIENTATION, STR("TCP RY Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 404, 2, HOLD_OFFSET(test_regs[20]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RZ_ORIENTATION, STR("TCP RZ Orientation"), STR("mrad"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 405, 1, HOLD_OFFSET(test_regs[21]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_X_SPEED, STR("TCP X Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 410, 2, HOLD_OFFSET(test_regs[22]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_Y_SPEED, STR("TCP Y Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 411, 2, HOLD_OFFSET(test_regs[23]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_Z_SPEED, STR("TCP Z Speed"), STR("mm/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 412, 2, HOLD_OFFSET(test_regs[24]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RX_SPEED, STR("TCP RX Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 413, 2, HOLD_OFFSET(test_regs[25]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RY_SPEED, STR("TCP RY Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 414, 2, HOLD_OFFSET(test_regs[26]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},
    {CID_TCP_RZ_SPEED, STR("TCP RZ Speed"), STR("mrad/s"), MB_DEVICE_ADDR1, MB_PARAM_HOLDING, 415, 1, HOLD_OFFSET(test_regs[27]), PARAM_TYPE_U16, 2, OPTS(0, 65535, 1), PAR_PERMS_READ},

};

// Calculate number of parameters in the table
const uint16_t num_device_parameters = (sizeof(device_parameters) / sizeof(device_parameters[0]));

// This table represents slave IP addresses that correspond to the short address field of the slave in device_parameters structure
// Modbus TCP stack shall use these addresses to be able to connect and read parameters from slave
#define MB_SLAVE_COUNT 1
char* slave_ip_address_table[] = {
    "192.168.1.102",  // Address corresponds to UR5
    // "192.168.1.103",  // Address corresponds to Debug PC
    NULL,  // End of table condition (must be included)
};

const size_t ip_table_sz = (size_t)(sizeof(slave_ip_address_table) / sizeof(slave_ip_address_table[0]));

/* Custom Variables */

static int s_active_interfaces = 0;

static esp_netif_t* s_ethernet_esp_netif = NULL;

static esp_ip4_addr_t s_ip_addr;

static esp_eth_handle_t s_eth_handle = NULL;
static esp_eth_mac_t* s_mac = NULL;
static esp_eth_phy_t* s_phy = NULL;
static esp_eth_netif_glue_handle_t s_eth_glue = NULL;

char* ip = "192.168.1.104";
char* gateway = "192.168.1.101";
char* netmask = "255.255.255.0";
/* Custom Variables */

/* Custom Functions */

esp_netif_t* get_eth_netif_from_desc(const char* desc) {
    esp_netif_t* netif = NULL;
    char* expected_desc;
    asprintf(&expected_desc, "%s: %s", TAG, desc);
    while ((netif = esp_netif_next(netif)) != NULL) {
        if (strcmp(esp_netif_get_desc(netif), expected_desc) == 0) {
            free(expected_desc);
            return netif;
        }
    }
    free(expected_desc);
    return netif;
}

esp_netif_t* get_eth_netif(void) {
    return s_ethernet_esp_netif;
}

static bool is_our_netif(const char* prefix, esp_netif_t* netif) {
    return strncmp(prefix, esp_netif_get_desc(netif), strlen(prefix) - 1) == 0;
}

/** Event handler for Ethernet events */
static void eth_event_handler(void* arg, esp_event_base_t event_base,
                              int32_t event_id, void* event_data) {
    // static const char* TAG = "eth_event_handler";

    uint8_t mac_addr[6] = {0};
    /* we can get the ethernet driver handle from event data */
    esp_eth_handle_t eth_handle = *(esp_eth_handle_t*)event_data;

    switch (event_id) {
        case ETHERNET_EVENT_CONNECTED:
            esp_eth_ioctl(eth_handle, ETH_CMD_G_MAC_ADDR, mac_addr);
            ESP_LOGI(TAG, "Ethernet Link Up");
            ESP_LOGI(TAG, "Ethernet HW Addr %02x:%02x:%02x:%02x:%02x:%02x",
                     mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3], mac_addr[4], mac_addr[5]);
            break;
        case ETHERNET_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "Ethernet Link Down");
            break;
        case ETHERNET_EVENT_START:
            ESP_LOGI(TAG, "Ethernet Started");
            break;
        case ETHERNET_EVENT_STOP:
            ESP_LOGI(TAG, "Ethernet Stopped");
            break;
        default:
            break;
    }
}

/** Event handler for IP_EVENT_ETH_GOT_IP */
static void on_got_ip(void* arg, esp_event_base_t event_base,
                      int32_t event_id, void* event_data) {
    ip_event_got_ip_t* event = (ip_event_got_ip_t*)event_data;
    if (!is_our_netif(TAG, event->esp_netif)) {
        ESP_LOGW(TAG, "Got IPv4 from another interface \"%s\": ignored", esp_netif_get_desc(event->esp_netif));
        return;
    }
    // const esp_netif_ip_info_t* ip_info = &event->ip_info;
    // // ESP_LOGI(TAG, "Ethernet Got IP Address");
    // // ESP_LOGI(TAG, "Ethernet IP: " IPSTR, IP2STR(&ip_info->ip));
    // // ESP_LOGI(TAG, "Ethernet NETMASK: " IPSTR, IP2STR(&ip_info->netmask));
    // // ESP_LOGI(TAG, "Ethernet GATEWAY: " IPSTR, IP2STR(&ip_info->gw));

    ESP_LOGI(TAG, "Got IPv4 event: Interface \"%s\" address: " IPSTR, esp_netif_get_desc(event->esp_netif), IP2STR(&event->ip_info.ip));
    memcpy(&s_ip_addr, &event->ip_info.ip, sizeof(s_ip_addr));
}

static esp_netif_t* eth_start(void) {
    // static const char* TAG = "ethernet_connect";
    ESP_LOGI(TAG, "Ethernet Start");

    char* desc;
    esp_netif_inherent_config_t esp_netif_config = ESP_NETIF_INHERENT_DEFAULT_ETH();
    // Prefix the interface description with the module TAG
    // Warning: the interface desc is used in tests to capture actual connection details (IP, gw, mask)
    asprintf(&desc, "%s: %s", TAG, esp_netif_config.if_desc);
    esp_netif_config.if_desc = desc;
    esp_netif_config.route_prio = 64;
    esp_netif_config_t netif_config = {
        .base = &esp_netif_config,
        .stack = ESP_NETIF_NETSTACK_DEFAULT_ETH};
    esp_netif_t* eth_netif = esp_netif_new(&netif_config);
    assert(eth_netif);
    free(desc);

    // Stop DHCP Client
    ESP_ERROR_CHECK(esp_netif_dhcpc_stop(eth_netif));

    esp_netif_ip_info_t info_t;
    memset(&info_t, 0, sizeof(esp_netif_ip_info_t));
    info_t.ip.addr = esp_ip4addr_aton((const char*)ip);
    info_t.gw.addr = esp_ip4addr_aton((const char*)gateway);
    info_t.netmask.addr = esp_ip4addr_aton((const char*)netmask);
    esp_netif_set_ip_info(eth_netif, &info_t);

    ESP_ERROR_CHECK(esp_eth_set_default_handlers(eth_netif));

    // Init MAC and PHY configs to default
    eth_mac_config_t mac_config = ETH_MAC_DEFAULT_CONFIG();
    eth_phy_config_t phy_config = ETH_PHY_DEFAULT_CONFIG();

    phy_config.phy_addr = CONFIG_EXAMPLE_ETH_PHY_ADDR;
    phy_config.reset_gpio_num = CONFIG_EXAMPLE_ETH_PHY_RST_GPIO;
    mac_config.smi_mdc_gpio_num = CONFIG_EXAMPLE_ETH_MDC_GPIO;
    mac_config.smi_mdio_gpio_num = CONFIG_EXAMPLE_ETH_MDIO_GPIO;

    s_mac = esp_eth_mac_new_esp32(&mac_config);
    s_phy = esp_eth_phy_new_lan87xx(&phy_config);

    // Install Ethernet driver
    esp_eth_config_t config = ETH_DEFAULT_CONFIG(s_mac, s_phy);
    ESP_ERROR_CHECK(esp_eth_driver_install(&config, &s_eth_handle));

    /* combine driver with netif */
    s_eth_glue = esp_eth_new_netif_glue(s_eth_handle);
    /* attach Ethernet driver to TCP/IP stack */
    ESP_ERROR_CHECK(esp_netif_attach(eth_netif, s_eth_glue));

    // Register user defined event handers
    ESP_ERROR_CHECK(esp_event_handler_register(IP_EVENT, IP_EVENT_ETH_GOT_IP, &on_got_ip, NULL));
    ESP_ERROR_CHECK(esp_event_handler_register(ETH_EVENT, ETHERNET_EVENT_CONNECTED, &eth_event_handler, eth_netif));

    /* start Ethernet driver state machine */
    ESP_ERROR_CHECK(esp_eth_start(s_eth_handle));

    return eth_netif;
}
static void eth_stop(void) {
    esp_netif_t* eth_netif = get_eth_netif_from_desc("eth");
    ESP_ERROR_CHECK(esp_event_handler_unregister(IP_EVENT, IP_EVENT_ETH_GOT_IP, &on_got_ip));
    ESP_ERROR_CHECK(esp_eth_stop(s_eth_handle));
    ESP_ERROR_CHECK(esp_eth_del_netif_glue(s_eth_glue));
    ESP_ERROR_CHECK(esp_eth_driver_uninstall(s_eth_handle));
    ESP_ERROR_CHECK(s_phy->del(s_phy));
    ESP_ERROR_CHECK(s_mac->del(s_mac));

    esp_netif_destroy(eth_netif);
    s_ethernet_esp_netif = NULL;
}

static void start(void) {
    s_ethernet_esp_netif = eth_start();
    s_active_interfaces++;
}
static void stop(void) {
    eth_stop();
    s_active_interfaces--;
}

esp_err_t ethernet_connect(void) {
    // static const char* TAG = "ethernet_connect";

    start();
    ESP_ERROR_CHECK(esp_register_shutdown_handler(&stop));
    // iterate over active interfaces, and print out IPs of "our" netifs
    esp_netif_t* netif = NULL;
    esp_netif_ip_info_t ip;
    for (int i = 0; i < esp_netif_get_nr_of_ifs(); ++i) {
        netif = esp_netif_next(netif);
        if (is_our_netif(TAG, netif)) {
            ESP_LOGI(TAG, "Connected to %s", esp_netif_get_desc(netif));
            ESP_ERROR_CHECK(esp_netif_get_ip_info(netif, &ip));

            ESP_LOGI(TAG, "- IPv4 address: " IPSTR, IP2STR(&ip.ip));
        }
    }

    ESP_LOGI(TAG, "Ethernet Connected!");

    return ESP_OK;
}

/* Custom Functions */

static void
master_destroy_slave_list(char** table, size_t ip_table_size) {
#if CONFIG_MB_MDNS_IP_RESOLVER
    slave_addr_entry_t* it;
    LIST_FOREACH(it, &slave_addr_list, entries) {
        LIST_REMOVE(it, entries);
        free(it);
    }
#endif
    for (int i = 0; ((i < ip_table_size) && table[i] != NULL); i++) {
        if (table[i]) {
#if CONFIG_MB_SLAVE_IP_FROM_STDIN
            free(table[i]);
            table[i] = "FROM_STDIN";
#elif CONFIG_MB_MDNS_IP_RESOLVER
            table[i] = NULL;
#endif
        }
    }
}

// The function to get pointer to parameter storage (instance) according to parameter description table
static void* master_get_param_data(const mb_parameter_descriptor_t* param_descriptor) {
    assert(param_descriptor != NULL);
    void* instance_ptr = NULL;
    if (param_descriptor->param_offset != 0) {
        switch (param_descriptor->mb_param_type) {
            case MB_PARAM_HOLDING:
                instance_ptr = ((void*)&holding_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_INPUT:
                instance_ptr = ((void*)&input_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_COIL:
                instance_ptr = ((void*)&coil_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_DISCRETE:
                instance_ptr = ((void*)&discrete_reg_params + param_descriptor->param_offset - 1);
                break;
            default:
                instance_ptr = NULL;
                break;
        }
    } else {
        ESP_LOGE(TAG, "Wrong parameter offset for CID #%d", param_descriptor->cid);
        assert(instance_ptr != NULL);
    }
    return instance_ptr;
}

// User operation function to read slave values and check alarm
static void master_operation_func(void* arg) {
    esp_err_t err = ESP_OK;
    uint16_t value = 0;
    bool alarm_state = false;
    const mb_parameter_descriptor_t* param_descriptor = NULL;

    ESP_LOGI(TAG, "Start modbus test...");

    for (uint16_t retry = 0; retry <= MASTER_MAX_RETRY && (!alarm_state); retry++) {
        // Read all found characteristics from slave(s)
        for (uint16_t cid = 0; (err != ESP_ERR_NOT_FOUND) && cid < MASTER_MAX_CIDS; cid++) {
            // Get data from parameters description table
            // and use this information to fill the characteristics description table
            // and having all required fields in just one table
            err = mbc_master_get_cid_info(cid, &param_descriptor);
            if ((err != ESP_ERR_NOT_FOUND) && (param_descriptor != NULL)) {
                void* temp_data_ptr = master_get_param_data(param_descriptor);
                assert(temp_data_ptr);
                uint8_t type = 0;
                err = mbc_master_get_parameter(cid, (char*)param_descriptor->param_key,
                                               (uint8_t*)&value, &type);
                if (err == ESP_OK) {
                    *(uint16_t*)temp_data_ptr = value;
                    if ((param_descriptor->mb_param_type == MB_PARAM_HOLDING) ||
                        (param_descriptor->mb_param_type == MB_PARAM_INPUT)) {
                        // ESP_LOGI(TAG, "Characteristic #%d %s (%s) value = %f (0x%x) read successful.",
                        //          param_descriptor->cid,
                        //          (char*)param_descriptor->param_key,
                        //          (char*)param_descriptor->param_units,
                        //          value,
                        //          *(uint32_t*)temp_data_ptr);
                        ESP_LOGI(TAG, "Characteristic #%d %s (%s) value = %d read successful.",
                                 param_descriptor->cid,
                                 (char*)param_descriptor->param_key,
                                 (char*)param_descriptor->param_units,
                                 value);
                        if (((value > param_descriptor->param_opts.max) ||
                             (value < param_descriptor->param_opts.min))) {
                            alarm_state = true;
                            break;
                        }
                    } else {
                        uint16_t state = *(uint16_t*)temp_data_ptr;
                        const char* rw_str = (state & param_descriptor->param_opts.opt1) ? "ON" : "OFF";
                        ESP_LOGI(TAG, "Characteristic #%d %s (%s) value = %s (0x%x) read successful.",
                                 param_descriptor->cid,
                                 (char*)param_descriptor->param_key,
                                 (char*)param_descriptor->param_units,
                                 (const char*)rw_str,
                                 *(uint16_t*)temp_data_ptr);
                        if (state & param_descriptor->param_opts.opt1) {
                            alarm_state = true;
                            break;
                        }
                    }
                } else {
                    ESP_LOGE(TAG, "Characteristic #%d (%s) read fail, err = %d (%s).",
                             param_descriptor->cid,
                             (char*)param_descriptor->param_key,
                             (int)err,
                             (char*)esp_err_to_name(err));
                }
                vTaskDelay(POLL_TIMEOUT_TICS);  // timeout between polls
            }
        }
        vTaskDelay(UPDATE_CIDS_TIMEOUT_TICS);
    }

    if (alarm_state) {
        ESP_LOGI(TAG, "Alarm triggered by cid #%d.",
                 param_descriptor->cid);
    } else {
        ESP_LOGE(TAG, "Alarm is not triggered after %d retries.",
                 MASTER_MAX_RETRY);
    }
    ESP_LOGI(TAG, "Destroy master...");
    vTaskDelay(100);
}

static esp_err_t init_services(mb_tcp_addr_type_t ip_addr_type) {
    esp_err_t result = nvs_flash_init();
    if (result == ESP_ERR_NVS_NO_FREE_PAGES || result == ESP_ERR_NVS_NEW_VERSION_FOUND) {
        ESP_ERROR_CHECK(nvs_flash_erase());
        result = nvs_flash_init();
    }

    ESP_ERROR_CHECK(esp_netif_init());
    ESP_ERROR_CHECK(esp_event_loop_create_default());
    ESP_ERROR_CHECK(ethernet_connect());
    // Configurate Slaves' IP Address
    return ESP_OK;
}

static esp_err_t destroy_services(void) {
    esp_err_t err = ESP_OK;
    master_destroy_slave_list(slave_ip_address_table, ip_table_sz);

    err = example_disconnect();
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "example_disconnect fail, returns(0x%x).",
                       (uint32_t)err);
    err = esp_event_loop_delete_default();
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "esp_event_loop_delete_default fail, returns(0x%x).",
                       (uint32_t)err);
    err = esp_netif_deinit();
    MB_RETURN_ON_FALSE((err == ESP_OK || err == ESP_ERR_NOT_SUPPORTED), ESP_ERR_INVALID_STATE,
                       TAG,
                       "esp_netif_deinit fail, returns(0x%x).",
                       (uint32_t)err);
    err = nvs_flash_deinit();
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "nvs_flash_deinit fail, returns(0x%x).",
                       (uint32_t)err);
    return err;
}

// Modbus master initialization
static esp_err_t master_init(mb_communication_info_t* comm_info) {
    void* master_handler = NULL;

    esp_err_t err = mbc_master_init_tcp(&master_handler);
    MB_RETURN_ON_FALSE((master_handler != NULL), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller initialization fail.");
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller initialization fail, returns(0x%x).",
                       (uint32_t)err);

    err = mbc_master_setup((void*)comm_info);
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller setup fail, returns(0x%x).",
                       (uint32_t)err);

    err = mbc_master_set_descriptor(&device_parameters[0], num_device_parameters);
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller set descriptor fail, returns(0x%x).",
                       (uint32_t)err);
    ESP_LOGI(TAG, "Modbus master stack initialized...");

    err = mbc_master_start();
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller start fail, returns(0x%x).",
                       (uint32_t)err);
    vTaskDelay(5);
    return err;
}

static esp_err_t master_destroy(void) {
    esp_err_t err = mbc_master_destroy();
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mbc_master_destroy fail, returns(0x%x).",
                       (uint32_t)err);
    ESP_LOGI(TAG, "Modbus master stack destroy...");
    return err;
}

void app_main(void) {
    mb_tcp_addr_type_t ip_addr_type = MB_IPV4;
    ESP_LOGI(TAG, "Initialiazing Services...");
    ESP_ERROR_CHECK(init_services(ip_addr_type));
    ESP_LOGI(TAG, "Services Initialized!");

    mb_communication_info_t comm_info = {0};
    comm_info.ip_port = MB_TCP_PORT;
    comm_info.ip_addr_type = ip_addr_type;
    comm_info.ip_mode = MB_MODE_TCP;
    comm_info.ip_addr = (void*)slave_ip_address_table;
    comm_info.ip_netif_ptr = (void*)get_eth_netif();

    ESP_LOGI(TAG, "Master init...");
    ESP_ERROR_CHECK(master_init(&comm_info));
    vTaskDelay(50);

    master_operation_func(NULL);
    // ESP_ERROR_CHECK(master_destroy());
    // ESP_ERROR_CHECK(destroy_services());
}
