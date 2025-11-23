#include <Wire.h>
#include <ESP8266WiFi.h>
#include <WebSocketsServer.h>

#define MPU_ADDR 0x69
#define ACCEL_XOUT_H 0x3B
#define GYRO_XOUT_H  0x43
#define PWR_MGMT_1   0x6B

// WiFi AP
const char* ssid = "ESP8266";
const char* pass = "12345678";

// WebSocket server
WebSocketsServer webSocket = WebSocketsServer(81);

// =========================
//    Đọc 16bit từ MPU
// =========================
int16_t readRegister16(uint8_t reg) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 2);
  while (Wire.available() < 2);
  uint8_t high = Wire.read();
  uint8_t low  = Wire.read();
  return (int16_t)(high << 8 | low);
}

// =========================
//         SETUP
// =========================
void setup() {
  Serial.begin(115200);

  // WiFi Access Point
  WiFi.softAP(ssid, pass);
  Serial.print("AP IP: ");
  Serial.println(WiFi.softAPIP());

  // WebSocket
  webSocket.begin();

  // MPU6050 init
  Wire.begin(D2, D1);
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(PWR_MGMT_1);
  Wire.write(0);  // wake up sensor
  Wire.endTransmission();
}

// =========================
//         LOOP
// =========================
void loop() {
  webSocket.loop();

  // Đọc gia tốc
  int16_t ax = readRegister16(ACCEL_XOUT_H);
  int16_t ay = readRegister16(ACCEL_XOUT_H + 2);
  int16_t az = readRegister16(ACCEL_XOUT_H + 4);

  float ax_g = ax / 16384.0;
  float ay_g = ay / 16384.0;
  float az_g = az / 16384.0;

  // Đọc gyro
  int16_t gx = readRegister16(GYRO_XOUT_H);
  int16_t gy = readRegister16(GYRO_XOUT_H + 2);
  int16_t gz = readRegister16(GYRO_XOUT_H + 4);

  float gx_dps = gx / 131.0;
  float gy_dps = gy / 131.0;
  float gz_dps = gz / 131.0;

  // Chuẩn bị chuỗi gửi
  String msg = "AX=" + String(ax_g, 3) +
               " AY=" + String(ay_g, 3) +
               " AZ=" + String(az_g, 3) +
               " GX=" + String(gx_dps, 3) +
               " GY=" + String(gy_dps, 3) +
               " GZ=" + String(gz_dps, 3);

  // Gửi qua WebSocket
  webSocket.broadcastTXT(msg);

  Serial.println(msg);

  delay(200);
}
