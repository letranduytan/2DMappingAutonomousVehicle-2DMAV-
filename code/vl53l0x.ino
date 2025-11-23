#include <Wire.h>

void setup() {
  Serial.begin(115200);
  Wire.begin(D2, D1);

  Serial.println("Scanning I2C...");
}

void loop() {
  byte error, address;
  int count = 0;

  for(address = 1; address < 127; address++ ) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();

    if (error == 0) {
      Serial.print("Found I2C device at: 0x");
      Serial.println(address, HEX);
      count++;
    }
  }

  if (count == 0) Serial.println("No I2C devices found!");
  else Serial.println("Done.");

  delay(2000);
}
