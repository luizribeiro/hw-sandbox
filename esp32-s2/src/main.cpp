#include <Arduino.h>
#include <Stepper.h>

const int stepsPerRevolution = 2038;
Stepper myStepper(stepsPerRevolution, 4, 2, 1, 3);

void setup() {
  pinMode(13, OUTPUT);
  myStepper.setSpeed(28);
}

void shutdownStepper() {
  digitalWrite(1, LOW);
  digitalWrite(2, LOW);
  digitalWrite(3, LOW);
  digitalWrite(4, LOW);
}

void loop() {
  digitalWrite(13, HIGH);
  myStepper.step(stepsPerRevolution);
  shutdownStepper();
  delay(5000);
  digitalWrite(13, LOW);
  myStepper.step(stepsPerRevolution);
  shutdownStepper();
  delay(5000);
}
