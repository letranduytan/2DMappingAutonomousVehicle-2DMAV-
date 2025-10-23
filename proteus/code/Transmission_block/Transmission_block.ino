// --- Ultrasonic Sensor Pins ---
const int trigPin = 7; 
const int echoPin = 6; 

// --- Motor Control Pins ---
// Motor 1
const int motor1_in1 = 13;
const int motor1_in2 = 12;
const int motor1_en = 11;  // PWM pin

// Motor 2
const int motor2_in1 = 9;
const int motor2_in2 = 8;
const int motor2_en = 10;  // PWM pin

void setup()
{
  Serial.begin(9600);

  // Ultrasonic Sensor
  pinMode(trigPin, OUTPUT);
  pinMode(echoPin, INPUT);

  // Motors
  pinMode(motor1_in1, OUTPUT);
  pinMode(motor1_in2, OUTPUT);
  pinMode(motor1_en, OUTPUT);

  pinMode(motor2_in1, OUTPUT);
  pinMode(motor2_in2, OUTPUT);
  pinMode(motor2_en, OUTPUT);

  // Set maximum motor speed (0 - 255)
  analogWrite(motor1_en, 255);
  analogWrite(motor2_en, 255);
}

void loop()
{
  long distance = getDistance();

  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");

  if (distance > 30) {
    moveForward();
  } else {
    stopMotor();
  }

  delay(100);
}

// ----------- Measure Distance Function -------------
long getDistance() {
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  long duration = pulseIn(echoPin, HIGH);
  long distanceCm = duration / 29 / 2;
  return distanceCm;
}

// ----------- Motor Control Functions ----------
void moveForward() {
  // Motor 1
  digitalWrite(motor1_in1, HIGH);
  digitalWrite(motor1_in2, LOW);
  // Motor 2
  digitalWrite(motor2_in1, HIGH);
  digitalWrite(motor2_in2, LOW);
}

void stopMotor() {
  digitalWrite(motor1_in1, LOW);
  digitalWrite(motor1_in2, LOW);
  digitalWrite(motor2_in1, LOW);
  digitalWrite(motor2_in2, LOW);
}
