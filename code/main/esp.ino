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
bool clientConnected = false;

// =========================
//         Encoder
// =========================
#define ENC1_PIN D6
#define ENC2_PIN D7

volatile long encoder1Count = 0;
volatile long encoder2Count = 0;

// Bán kính bánh xe (m)
const float WHEEL_RADIUS = 0.0325;  // 65mm đường kính → 32.5mm bán kính
// Số xung trên 1 vòng bánh xe
const int PULSES_PER_REV = 20;

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
//  Encoder ISRs
// =========================
void IRAM_ATTR encoder1ISR() { encoder1Count++; }
void IRAM_ATTR encoder2ISR() { encoder2Count++; }

// =========================
//  WebSocket callback
// =========================
void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  if(type == WStype_CONNECTED) {
    Serial.println("Client connected");
    clientConnected = true;
  } else if(type == WStype_DISCONNECTED) {
    Serial.println("Client disconnected");
    clientConnected = false;
  }
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
  webSocket.onEvent(webSocketEvent);

  // MPU6050 init
  Wire.begin(D2, D1);
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(PWR_MGMT_1);
  Wire.write(0);  // wake up sensor
  Wire.endTransmission();

  // Encoder init
  pinMode(ENC1_PIN, INPUT_PULLUP);
  pinMode(ENC2_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(ENC1_PIN), encoder1ISR, RISING);
  attachInterrupt(digitalPinToInterrupt(ENC2_PIN), encoder2ISR, RISING);
}

// =========================
//         LOOP
// =========================
unsigned long lastTime = 0;

void loop() {
  webSocket.loop();

  unsigned long now = millis();
  unsigned long dt = now - lastTime;

  if(dt >= 200) { // tính tốc độ mỗi 200ms
    lastTime = now;

    // Lấy giá trị encoder và reset bộ đếm tạm
    long enc1 = encoder1Count;
    long enc2 = encoder2Count;
    encoder1Count = 0;
    encoder2Count = 0;

    // Tính tốc độ (m/s)
    float rev1 = (float)enc1 / PULSES_PER_REV;
    float rev2 = (float)enc2 / PULSES_PER_REV;
    float speed1 = (2 * 3.14159 * WHEEL_RADIUS * rev1) / (dt / 1000.0);
    float speed2 = (2 * 3.14159 * WHEEL_RADIUS * rev2) / (dt / 1000.0);

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
                 " GZ=" + String(gz_dps, 3) +
                 " SPD1=" + String(speed1, 3) +
                 " SPD2=" + String(speed2, 3);

    if(clientConnected) webSocket.broadcastTXT(msg);
    Serial.println(msg);
  }
}
