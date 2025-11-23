// =====================================
//         PIN CONFIG
// =====================================
const int motor1_in1 = 13;
const int motor1_in2 = 12;
const int motor1_en  = 11;  // PWM

const int motor2_in1 = 9;
const int motor2_in2 = 8;
const int motor2_en  = 10;  // PWM

// Encoder
const int enc1 = 3;
const int enc2 = 2;

volatile long count1 = 0;
volatile long count2 = 0;

// Ultrasonic
const int trigPin = 7;
const int echoPin = 6;

// =====================================
//        PID CONFIG
// =====================================
float kp = 6.0;
float ki = 0.5;
float kd = 0.6;
float dt = 0.08;  // 80ms

int baseSpeed = 80;
int correctionLimit = 40;

float error = 0;
float lastError = 0;
float integral = 0;

float speed1Filt = 0;
float speed2Filt = 0;

// =====================================
//       BROWNOUT + SAFETY FUNCTIONS
// =====================================
long readVcc() {
  ADMUX = _BV(REFS0) | _BV(MUX3) | _BV(MUX2) | _BV(MUX1);
  delay(2);
  ADCSRA |= _BV(ADSC);
  while (bit_is_set(ADCSRA, ADSC));
  long result = ADCL;
  result |= ADCH << 8;
  return 1125300L / result;
}

void checkBrownout() {
  long v = readVcc();
  if (v < 4600) {
    Serial.print("BROWNOUT! Vcc=");
    Serial.println(v);
    delay(50);
    asm volatile ("jmp 0");
  }
}

float safeValueFloat(float x, float minV, float maxV) {
  if (x < minV || x > maxV) return 0;
  return x;
}

// =====================================
//          MOTOR FUNCTIONS
// =====================================
void moveForward(int p1, int p2) {
  digitalWrite(motor1_in1, HIGH);
  digitalWrite(motor1_in2, LOW);
  analogWrite(motor1_en, p1);

  digitalWrite(motor2_in1, HIGH);
  digitalWrite(motor2_in2, LOW);
  analogWrite(motor2_en, p2);
}

void moveStop() {
  analogWrite(motor1_en, 0);
  analogWrite(motor2_en, 0);
  digitalWrite(motor1_in1, LOW);
  digitalWrite(motor1_in2, LOW);
  digitalWrite(motor2_in1, LOW);
  digitalWrite(motor2_in2, LOW);
}

// =====================================
//           ULTRASONIC
// =====================================
long getDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH, 20000);
  long distanceCm = duration / 29 / 2;

  return constrain(distanceCm, 0, 400);
}

// Trung bình 5 lần đo (float, 2 chữ số)
float getDistanceAvg(int samples = 5) {
  long sum = 0;
  for (int i = 0; i < samples; i++) {
    sum += getDistance();
    delay(5);
  }
  float avg = (float)sum / samples;
  return round(avg * 100.0) / 100.0;
}

// =====================================
//         ENCODER INTERRUPTS
// =====================================
void encoder1() { count1++; }
void encoder2() { count2++; }

// =====================================
//               SETUP
// =====================================
void setup() {
  Serial.begin(115200);

  pinMode(motor1_in1, OUTPUT);
  pinMode(motor1_in2, OUTPUT);
  pinMode(motor1_en, OUTPUT);

  pinMode(motor2_in1, OUTPUT);
  pinMode(motor2_in2, OUTPUT);
  pinMode(motor2_en, OUTPUT);

  pinMode(enc1, INPUT_PULLUP);
  pinMode(enc2, INPUT_PULLUP);

  attachInterrupt(digitalPinToInterrupt(enc1), encoder1, RISING);
  attachInterrupt(digitalPinToInterrupt(enc2), encoder2, RISING);

  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  Serial.println("=== ROBOT START ===");
}

// =====================================
//                LOOP
// =====================================
void loop() {
  checkBrownout();
  delay(50);

  float dist = safeValueFloat(getDistanceAvg(5), 0, 400);

  noInterrupts();
  long c1 = count1;
  long c2 = count2;
  count1 = 0;
  count2 = 0;
  interrupts();

  c1 = constrain(c1, 0, 2000);
  c2 = constrain(c2, 0, 2000);

  float speed1 = c1 / dt;
  float speed2 = c2 / dt;

  speed1Filt = speed1Filt * 0.8 + speed1 * 0.2;
  speed2Filt = speed2Filt * 0.8 + speed2 * 0.2;

  error = speed1Filt - speed2Filt;

  if (abs(error) < 20) {
    integral += error * dt;
  }

  float derivative = (error - lastError) / dt;
  lastError = error;

  float correction = kp * error + ki * integral + kd * derivative;
  correction = constrain(correction, -correctionLimit, correctionLimit);

  int pwm1_raw = constrain(baseSpeed - correction, 0, 255);
  int pwm2_raw = constrain(baseSpeed + correction, 0, 255);

  static float pwm1 = 0;
  static float pwm2 = 0;

  pwm1 = pwm1 * 0.7 + pwm1_raw * 0.3;
  pwm2 = pwm2 * 0.7 + pwm2_raw * 0.3;

  // ========== OBSTACLE ==========
  if (dist < 15) {
    moveStop();
    delay(500);
  } 
  else {
    moveForward(pwm1, pwm2);
  }

  // SERIAL DEBUG
  Serial.print("Dist: "); Serial.print(dist, 2);
  Serial.print(" | S1: "); Serial.print(speed1Filt, 2);
  Serial.print(" | S2: "); Serial.print(speed2Filt, 2);
  Serial.print(" | PWM1: "); Serial.print(pwm1, 2);
  Serial.print(" | PWM2: "); Serial.print(pwm2, 2);
  Serial.print(" | Err: "); Serial.println(error, 2);
}
