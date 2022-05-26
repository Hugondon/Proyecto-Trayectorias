/*
       Modbus Master  Driver
*/
#include "modbus_master.h"

#include "configurations.h"
#include "driver/gpio.h"
#include "ethernet-wifi-connect.h"
#include "modbus_data.h"
#include "tasks_common.h"
#define SLAVE_IP_ADDRESS MB_SLAVE_IP_ADDRESS

extern QueueHandle_t ProcessingQueue;
static const char *TAG = "MBMaster";

holding_reg_params_t holding_reg_params;
input_reg_params_t input_reg_params;
coil_reg_params_t coil_reg_params;
discrete_reg_params_t discrete_reg_params;

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

char *slave_ip_address_table[] = {
    SLAVE_IP_ADDRESS,
    NULL,  // End of table condition (must be included)
};
// Calculate number of parameters in the table
const uint16_t num_device_parameters = (sizeof(device_parameters) / sizeof(device_parameters[0]));

const size_t ip_table_sz = (size_t)(sizeof(slave_ip_address_table) / sizeof(slave_ip_address_table[0]));

// Modbus master initialization
esp_err_t master_init(mb_communication_info_t *comm_info) {
    void *master_handler = NULL;

    esp_err_t err = mbc_master_init_tcp(&master_handler);
    MB_RETURN_ON_FALSE((master_handler != NULL), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller initialization fail.");
    MB_RETURN_ON_FALSE((err == ESP_OK), ESP_ERR_INVALID_STATE,
                       TAG,
                       "mb controller initialization fail, returns(0x%x).",
                       (uint32_t)err);

    err = mbc_master_setup((void *)comm_info);
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

void mb_communication_init(void) {
    mb_communication_info_t comm_info = {0};
    comm_info.ip_port = MB_TCP_PORT;
    comm_info.ip_addr_type = MB_IPV4;
    comm_info.ip_mode = MB_MODE_TCP;
    comm_info.ip_addr = (void *)slave_ip_address_table;
    comm_info.ip_netif_ptr = (void *)get_eth_netif();
    ESP_ERROR_CHECK(master_init(&comm_info));
}

// The function to get pointer to parameter storage (instance) according to parameter description table
void *master_get_param_data(const mb_parameter_descriptor_t *param_descriptor) {
    assert(param_descriptor != NULL);
    void *instance_ptr = NULL;
    if (param_descriptor->param_offset != 0) {
        switch (param_descriptor->mb_param_type) {
            case MB_PARAM_HOLDING:
                instance_ptr = ((void *)&holding_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_INPUT:
                instance_ptr = ((void *)&input_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_COIL:
                instance_ptr = ((void *)&coil_reg_params + param_descriptor->param_offset - 1);
                break;
            case MB_PARAM_DISCRETE:
                instance_ptr = ((void *)&discrete_reg_params + param_descriptor->param_offset - 1);
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

void master_operation_func(void *arg) {
    esp_err_t err = ESP_OK;
    uint16_t value = 0;
    const mb_parameter_descriptor_t *param_descriptor = NULL;

    extern QueueHandle_t ProcessingQueue;

    MB_data_t current_data;

    ESP_LOGI(TAG, "Start Modbus Master...");
    gpio_set_level(LED_GREEN_GPIO, 1);

    for (;;) {
        // Read all found characteristics from slave(s)
        for (uint16_t cid = 0; (err != ESP_ERR_NOT_FOUND) && cid < MASTER_MAX_CIDS;) {
            err = mbc_master_get_cid_info(cid, &param_descriptor);
            if ((err != ESP_ERR_NOT_FOUND) && (param_descriptor != NULL)) {
                void *temp_data_ptr = master_get_param_data(param_descriptor);
                assert(temp_data_ptr);
                uint8_t type = 0;
                err = mbc_master_get_parameter(cid, (char *)param_descriptor->param_key,
                                               (uint8_t *)&value, &type);
                if (err == ESP_OK) {
                    *(float *)temp_data_ptr = value;
                    if ((param_descriptor->mb_param_type == MB_PARAM_HOLDING) ||
                        (param_descriptor->mb_param_type == MB_PARAM_INPUT)) {
                        // ESP_LOGI(TAG, "Characteristic #%d %s (%s) value = %d (0x%x) read successful.",
                        //          param_descriptor->cid,
                        //          (char *)param_descriptor->param_key,
                        //          (char *)param_descriptor->param_units,
                        //          value,
                        //          *(uint32_t *)temp_data_ptr);
                        current_data.cid = param_descriptor->cid;
                        current_data.value = value;

                        if (!xQueueSend(ProcessingQueue, &current_data, pdMS_TO_TICKS(10))) {
                            ESP_LOGE(TAG, "Error sending #%d %s with value %d to Processing Queue!", current_data.cid, (char *)param_descriptor->param_key, current_data.value);
                        } else {
                            ESP_LOGI(TAG, "#%d %s with value %d sent to Processing Queue!", current_data.cid, (char *)param_descriptor->param_key, current_data.value);
                        }
                        cid++;
                    }
                } else {
                    ESP_LOGE(TAG, "Characteristic #%d (%s) read fail, err = %d (%s).",
                             param_descriptor->cid,
                             (char *)param_descriptor->param_key,
                             (int)err,
                             (char *)esp_err_to_name(err));
                }
                vTaskDelay(MB_MASTER_TASK_POLL_BLOCK_TIME_MS / portTICK_RATE_MS);  // timeout between polls
            }
        }
        vTaskDelay(MB_MASTER_TASK_CIDS_BLOCK_TIME_MS / portTICK_RATE_MS);
    }
}

void mb_master_start(void) {
    ESP_LOGI(TAG, "STARTING Modbus Master Application");

    // Initializing modbus master
    mb_communication_init();
    // Start the Modbus Master operations task
    master_operation_func(NULL);
}