/*
       HTTP Requests Driver

*/

#include "requests.h"

#include "configurations.h"
#include "freertos/semphr.h"
#include "processing.h"
#include "tasks_common.h"

static const char *TAG = "HTTP Client";
SemaphoreHandle_t received_data_semaphore;

esp_err_t client_event_handler(esp_http_client_event_t *evt) {
    switch (evt->event_id) {
        case HTTP_EVENT_ERROR:
            ESP_LOGD(TAG, "HTTP_EVENT_ERROR");
            break;
        case HTTP_EVENT_ON_CONNECTED:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_CONNECTED");
            break;
        case HTTP_EVENT_HEADER_SENT:
            ESP_LOGD(TAG, "HTTP_EVENT_HEADER_SENT");
            break;
        case HTTP_EVENT_ON_HEADER:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_HEADER, key=%s, value=%s", evt->header_key, evt->header_value);
            break;
        case HTTP_EVENT_ON_DATA:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_DATA, len=%d", evt->data_len);
            printf("Data: %.*s\n", evt->data_len, (char *)evt->data);
            break;
        case HTTP_EVENT_ON_FINISH:
            ESP_LOGD(TAG, "HTTP_EVENT_ON_FINISH");
            break;
        case HTTP_EVENT_DISCONNECTED:
            ESP_LOGI(TAG, "HTTP_EVENT_DISCONNECTED");
            break;
        default:
            break;
    }
    return ESP_OK;
}

void http_client_task(void *pvParameters) {
    extern QueueHandle_t TransmissionQueue;

    // Semaphore
    received_data_semaphore = xSemaphoreCreateBinary();

    transmitted_float_data_t modbus_float_data;
    static uint8_t data_count = 0;
    char *mesage_payload;

    int robot_state_mode = 9;
    int robot_state_power_on = 1;
    int robot_state_security_stopped = 1;
    int robot_state_emergency_stopped = 1;

    float joint_angle_base_mrad = 3.14;
    float joint_angle_shoulder_mrad = 3.14;
    float joint_angle_elbow_mrad = 3.14;
    float joint_angle_wrist_1_mrad = 3.14;
    float joint_angle_wrist_2_mrad = 3.14;
    float joint_angle_wrist_3_mrad = 3.14;

    float joint_angle_velocity_base_mrad_s = 3.14;
    float joint_angle_velocity_shoulder_mrad_s = 3.14;
    float joint_angle_velocity_elbow_mrad_s = 3.14;
    float joint_angle_velocity_wrist_1_mrad_s = 3.14;
    float joint_angle_velocity_wrist_2_mrad_s = 3.14;
    float joint_angle_velocity_wrist_3_mrad_s = 3.14;

    float tcp_position_x_tenth_mm = 2.5;
    float tcp_position_y_tenth_mm = 2.5;
    float tcp_position_z_tenth_mm = 2.5;
    float tcp_orientation_x_mrad = 1.1;
    float tcp_orientation_y_mrad = 1.1;
    float tcp_orientation_z_mrad = 1.1;

    float tcp_speed_x_mm_s = 4.5;
    float tcp_speed_y_mm_s = 4.5;
    float tcp_speed_z_mm_s = 4.5;
    float tcp_speed_rx_mrad_s = 4.5;
    float tcp_speed_ry_mrad_s = 4.5;
    float tcp_speed_rz_mrad_s = 4.5;

    esp_http_client_config_t client_configuration = {
        .url = URL,
        .method = HTTP_METHOD_POST};

    esp_http_client_handle_t client = esp_http_client_init(&client_configuration);
    esp_http_client_set_header(client, "CONTENT-TYPE", "application/json");

    for (;;) {
        if (!xQueueReceive(TransmissionQueue, &modbus_float_data, pdMS_TO_TICKS(10))) {
            ESP_LOGE(TAG, "Error receiving value from Transmission Queue!");
        } else {
            ESP_LOGI(TAG, "#%d with value %f received from Processing Queue", modbus_float_data.cid, modbus_float_data.value);

            switch (data_count) {
                case 0:
                    robot_state_mode = (int)(modbus_float_data.value);
                    break;
                case 1:
                    robot_state_power_on = (int)(modbus_float_data.value);
                    break;
                case 2:
                    robot_state_security_stopped = (int)(modbus_float_data.value);
                    break;
                case 3:
                    robot_state_emergency_stopped = (int)(modbus_float_data.value);
                    break;
                case 4:
                    joint_angle_base_mrad = modbus_float_data.value;
                    break;
                case 5:
                    joint_angle_shoulder_mrad = modbus_float_data.value;
                    break;
                case 6:
                    joint_angle_elbow_mrad = modbus_float_data.value;
                    break;
                case 7:
                    joint_angle_wrist_1_mrad = modbus_float_data.value;
                    break;
                case 8:
                    joint_angle_wrist_2_mrad = modbus_float_data.value;
                    break;
                case 9:
                    joint_angle_wrist_3_mrad = modbus_float_data.value;
                    break;
                case 10:
                    joint_angle_velocity_base_mrad_s = modbus_float_data.value;
                    break;
                case 11:
                    joint_angle_velocity_shoulder_mrad_s = modbus_float_data.value;
                    break;
                case 12:
                    joint_angle_velocity_elbow_mrad_s = modbus_float_data.value;
                    break;
                case 13:
                    joint_angle_velocity_wrist_1_mrad_s = modbus_float_data.value;
                    break;
                case 14:
                    joint_angle_velocity_wrist_2_mrad_s = modbus_float_data.value;
                    break;
                case 15:
                    joint_angle_velocity_wrist_3_mrad_s = modbus_float_data.value;
                    break;
                case 16:
                    tcp_position_x_tenth_mm = modbus_float_data.value;
                    break;
                case 17:
                    tcp_position_y_tenth_mm = modbus_float_data.value;
                    break;
                case 18:
                    tcp_position_z_tenth_mm = modbus_float_data.value;
                    break;
                case 19:
                    tcp_orientation_x_mrad = modbus_float_data.value;
                    break;
                case 20:
                    tcp_orientation_y_mrad = modbus_float_data.value;
                    break;
                case 21:
                    tcp_orientation_z_mrad = modbus_float_data.value;
                    break;
                case 22:
                    tcp_speed_x_mm_s = modbus_float_data.value;
                    break;
                case 23:
                    tcp_speed_y_mm_s = modbus_float_data.value;
                    break;
                case 24:
                    tcp_speed_z_mm_s = modbus_float_data.value;
                    break;
                case 25:
                    tcp_speed_rx_mrad_s = modbus_float_data.value;
                    break;
                case 26:
                    tcp_speed_ry_mrad_s = modbus_float_data.value;
                    break;
                case 27:
                    tcp_speed_rz_mrad_s = modbus_float_data.value;
                    break;
                default:
                    break;
            }
            data_count++;
            if (data_count == 28) {
                xSemaphoreGive(received_data_semaphore);
            }
        }
        if (xSemaphoreTake(received_data_semaphore, 0)) {
            ESP_LOGI(TAG, "Posting!");

            /* Generate JSON */
            cJSON *json = cJSON_CreateObject();

            cJSON *robot_state_array = cJSON_AddArrayToObject(json, "Robot_State");

            cJSON *mode_json = cJSON_CreateObject();
            cJSON_AddItemToArray(robot_state_array, mode_json);
            cJSON_AddNumberToObject(mode_json, "Mode", robot_state_mode);

            cJSON *power_on_json = cJSON_CreateObject();
            cJSON_AddItemToArray(robot_state_array, power_on_json);
            cJSON_AddNumberToObject(power_on_json, "Power_ON", robot_state_power_on);

            cJSON *security_stopped_json = cJSON_CreateObject();
            cJSON_AddItemToArray(robot_state_array, security_stopped_json);
            cJSON_AddNumberToObject(security_stopped_json, "Security_Stopped", robot_state_security_stopped);

            cJSON *emergency_stopped_json = cJSON_CreateObject();
            cJSON_AddItemToArray(robot_state_array, emergency_stopped_json);
            cJSON_AddNumberToObject(emergency_stopped_json, "Emergency_Stopped", robot_state_emergency_stopped);

            cJSON *joint_angle_array = cJSON_AddArrayToObject(json, "Joint_Angle");

            cJSON *base_mrad_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, base_mrad_json);
            cJSON_AddNumberToObject(base_mrad_json, "Base_mrad", joint_angle_base_mrad);

            cJSON *shoulder_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, shoulder_json);
            cJSON_AddNumberToObject(shoulder_json, "Shoulder_mrad", joint_angle_shoulder_mrad);

            cJSON *elbow_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, elbow_json);
            cJSON_AddNumberToObject(elbow_json, "Elbow_mrad", joint_angle_elbow_mrad);

            cJSON *wrist_1_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, wrist_1_json);
            cJSON_AddNumberToObject(wrist_1_json, "Wrist1_mrad", joint_angle_wrist_1_mrad);

            cJSON *wrist_2_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, wrist_2_json);
            cJSON_AddNumberToObject(wrist_2_json, "Wrist2_mrad", joint_angle_wrist_2_mrad);

            cJSON *wrist_3_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_array, wrist_3_json);
            cJSON_AddNumberToObject(wrist_3_json, "Wrist3_mrad", joint_angle_wrist_3_mrad);

            cJSON *joint_angle_velocity_array = cJSON_AddArrayToObject(json, "Joint_Angle_Velocity");
            cJSON *base_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, base_mrad_s_json);
            cJSON_AddNumberToObject(base_mrad_s_json, "Base_mrad_s", joint_angle_velocity_base_mrad_s);

            cJSON *shoulder_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, shoulder_mrad_s_json);
            cJSON_AddNumberToObject(shoulder_mrad_s_json, "Shoulder_mrad_s", joint_angle_velocity_shoulder_mrad_s);

            cJSON *elbow_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, elbow_mrad_s_json);
            cJSON_AddNumberToObject(elbow_mrad_s_json, "Elbow_mrad_s", joint_angle_velocity_elbow_mrad_s);

            cJSON *wrist_1_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, wrist_1_mrad_s_json);
            cJSON_AddNumberToObject(wrist_1_mrad_s_json, "Wrist1_mrad_s", joint_angle_velocity_wrist_1_mrad_s);

            cJSON *wrist_2_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, wrist_2_mrad_s_json);
            cJSON_AddNumberToObject(wrist_2_mrad_s_json, "Wrist2_mrad_s", joint_angle_velocity_wrist_2_mrad_s);

            cJSON *wrist_3_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(joint_angle_velocity_array, wrist_3_mrad_s_json);
            cJSON_AddNumberToObject(wrist_3_mrad_s_json, "Wrist3_mrad_s", joint_angle_velocity_wrist_3_mrad_s);

            cJSON *tcp_position_orientation_array = cJSON_AddArrayToObject(json, "TCP_Position_Orientation");
            cJSON *x_tenth_mm_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, x_tenth_mm_json);
            cJSON_AddNumberToObject(x_tenth_mm_json, "X_tenth_mm", tcp_position_x_tenth_mm);

            cJSON *y_tenth_mm_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, y_tenth_mm_json);
            cJSON_AddNumberToObject(y_tenth_mm_json, "Y_tenth_mm", tcp_position_y_tenth_mm);

            cJSON *z_tenth_mm_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, z_tenth_mm_json);
            cJSON_AddNumberToObject(z_tenth_mm_json, "Z_tenth_mm", tcp_position_z_tenth_mm);

            cJSON *rx_mrad_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, rx_mrad_json);
            cJSON_AddNumberToObject(rx_mrad_json, "RX_mrad", tcp_orientation_x_mrad);

            cJSON *ry_mrad_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, ry_mrad_json);
            cJSON_AddNumberToObject(ry_mrad_json, "RY_mrad", tcp_orientation_y_mrad);

            cJSON *rz_mrad_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_position_orientation_array, rz_mrad_json);
            cJSON_AddNumberToObject(rz_mrad_json, "RZ_mrad", tcp_orientation_z_mrad);

            cJSON *tcp_speed_array = cJSON_AddArrayToObject(json, "TCP_Speed");
            cJSON *x_mm_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, x_mm_s_json);
            cJSON_AddNumberToObject(x_mm_s_json, "X_mm_s", tcp_speed_x_mm_s);

            cJSON *y_mm_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, y_mm_s_json);
            cJSON_AddNumberToObject(y_mm_s_json, "Y_mm_s", tcp_speed_y_mm_s);

            cJSON *z_mm_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, z_mm_s_json);
            cJSON_AddNumberToObject(z_mm_s_json, "Z_mm_s", tcp_speed_z_mm_s);

            cJSON *rx_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, rx_mrad_s_json);
            cJSON_AddNumberToObject(rx_mrad_s_json, "RX_mrad_s", tcp_speed_rx_mrad_s);

            cJSON *ry_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, ry_mrad_s_json);
            cJSON_AddNumberToObject(ry_mrad_s_json, "RY_mrad_s", tcp_speed_ry_mrad_s);

            cJSON *rz_mrad_s_json = cJSON_CreateObject();
            cJSON_AddItemToArray(tcp_speed_array, rz_mrad_s_json);
            cJSON_AddNumberToObject(rz_mrad_s_json, "RZ_mrad_s", tcp_speed_rz_mrad_s);

            mesage_payload = cJSON_Print(json);
            /* Generate JSON */
            esp_http_client_set_post_field(client, mesage_payload, strlen((mesage_payload)));
            esp_err_t err = esp_http_client_perform(client);
            if (err == ESP_OK) {
                int length = esp_http_client_get_content_length(client);
                char *response_payload = malloc(length + 1);
                memset(response_payload, 0, length + 1);
                esp_http_client_read(client, response_payload, length);
                cJSON *json_response = cJSON_Parse(response_payload);
                cJSON *response_message = cJSON_GetObjectItem(json_response, "message");
                if (response_message) {
                    printf("%s\n", response_message->valuestring);
                } else {
                    printf("No response!\nb");
                }
                cJSON_Delete(json_response);
            } else {
                ESP_LOGE(TAG, "HTTP POST request failed: %s", esp_err_to_name(err));
            }

            cJSON_Delete(json);
            data_count = 0;
        } else {
            ESP_LOGI(TAG, "Only %d data have been received, not ready to post!", data_count);
        }
        // esp_http_client_cleanup(client);

        vTaskDelay(HTTP_CLIENT_TASK_BLOCK_TIME_MS / portTICK_PERIOD_MS);
    }
}

void http_client_start(void) {
    ESP_LOGI(TAG, "STARTING HTTP Client Application");

    // Start the HTTP application task
    xTaskCreatePinnedToCore(&http_client_task, "http_client_task", HTTP_CLIENT_TASK_STACK_SIZE, NULL, HTTP_CLIENT_TASK_PRIORITY, NULL, HTTP_CLIENT_TASK_CODE_ID);
}
