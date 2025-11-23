#include <Wire.h>

#define MPU_ADDR 0x69  // Địa chỉ bạn scan được
// Register addresses
#define ACCEL_XOUT_H 0x3B
#define GYRO_XOUT_H  0x43
#define PWR_MGMT_1   0x6B

void setup() {
  Serial.begin(115200);
  Wire.begin(D2, D1); // SDA, SCL
  delay(1000);

  // Khởi động MPU (wake up)
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(PWR_MGMT_1);
  Wire.write(0); // Xóa sleep bit
  Wire.endTransmission();

  // Kiểm tra WHO_AM_I
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(0x75);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 1);
  if (Wire.available()) {
    byte whoami = Wire.read();
    Serial.print("WHO_AM_I = 0x"); Serial.println(whoami, HEX);
    if (whoami == 0x68 || whoami == 0x69 || whoami == 0x70) {
      Serial.println("MPU detected (including clone)!");
    } else {
      Serial.println("Unknown MPU device!");
    }
  }
}

int16_t readRegister16(uint8_t reg) {
  Wire.beginTransmission(MPU_ADDR);
  Wire.write(reg);
  Wire.endTransmission(false);
  Wire.requestFrom(MPU_ADDR, 2);
  while (Wire.available() < 2);
  uint8_t high = Wire.read();
  uint8_t low = Wire.read();
  return (int16_t)(high << 8 | low);
}

void loop() {
  // Đọc gia tốc
  int16_t ax = readRegister16(ACCEL_XOUT_H);
  int16_t ay = readRegister16(ACCEL_XOUT_H + 2);
  int16_t az = readRegister16(ACCEL_XOUT_H + 4);

  // Đọc gyro
  int16_t gx = readRegister16(GYRO_XOUT_H);
  int16_t gy = readRegister16(GYRO_XOUT_H + 2);
  int16_t gz = readRegister16(GYRO_XOUT_H + 4);

  // Chuyển sang đơn vị g và deg/s nếu muốn
  float aScale = 16384.0; // ±2g
  float gScale = 131.0;   // ±250°/s

  Serial.print("Accel (g): X="); Serial.print(ax / aScale);
  Serial.print(" Y="); Serial.print(ay / aScale);
  Serial.print(" Z="); Serial.println(az / aScale);

  Serial.print("Gyro (°/s): X="); Serial.print(gx / gScale);
  Serial.print(" Y="); Serial.print(gy / gScale);
  Serial.print(" Z="); Serial.println(gz / gScale);

  Serial.println("---------------------");
  delay(500);
}
