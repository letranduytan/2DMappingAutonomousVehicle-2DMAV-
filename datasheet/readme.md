# Sensor Details

### 1. **Ultrasonic Sensor – HC-SR04**

| Parameter | Specification |
|------------|----------------|
| Measurement range | 2 – 400 cm |
| Resolution | 0.3 cm |
| Accuracy | ±3 mm |
| Effective angle | ±15° |
| Frequency | 40 kHz |
| Supply voltage | 5V DC |
| Response time | < 50 ms |
| Interface | Trigger / Echo |

 
**Application:** Short-range obstacle detection and avoidance.

---

### 2. **Laser Distance Sensor – VL53L0X (ToF)**

| Parameter | Specification |
|------------|----------------|
| Technology | Time-of-Flight (ToF) |
| Measurement range | 30 mm – 2000 mm |
| Resolution | 1 mm |
| Accuracy | ±3% |
| Response time | 20–33 ms |
| Interface | I²C (Address 0x29) |
| Supply voltage | 2.6 – 3.5V |
| Field of View (FoV) | ±25° |
| Module size | 4.4 × 2.4 × 1.0 mm |


**Application:** Precise distance sensing and 2D mapping.

---

### 3. **IMU Sensor – MPU-6050 (GY-521)**

| Parameter | Specification |
|------------|----------------|
| Axes | 3-axis accelerometer + 3-axis gyroscope |
| ADC Resolution | 16-bit |
| Acceleration range | ±2g / ±4g / ±8g / ±16g |
| Gyroscope range | ±250 / ±500 / ±1000 / ±2000 °/s |
| Sampling rate | 1 Hz – 1 kHz |
| Supply voltage | 3–5V |
| Communication | I²C |
| Operating temperature | –40°C to +105°C |

**Function:**  
Combines accelerometer and gyroscope data to determine the robot’s orientation (Pitch, Roll, Yaw).  
Includes an internal **Digital Motion Processor (DMP)** for sensor fusion and filtering.  

**Application:** Attitude estimation and motion tracking.

---

### 4. **Rotary Encoder – KY-040**

| Parameter | Specification |
|------------|----------------|
| Type | Mechanical incremental encoder |
| Resolution | 20 steps/rev (≈18°/step) |
| Output | Digital TTL (A/B channels) |
| Supply voltage | 3.3V – 5V |
| Response time | Instantaneous |
| Debounce | Required (hardware or software) |


**Application:** Wheel odometry and speed measurement.

---

## Conclusion

The **Mobile Path-Finding Robot** integrates multiple sensors and embedded control techniques to simulate basic autonomous vehicle behavior:  
- **Ultrasonic + Laser sensors:** Environment perception and obstacle avoidance.  
- **Encoder + IMU:** Motion and orientation tracking.  
- **Microcontroller + PC:** Data processing and 2D map reconstruction.
