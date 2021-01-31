#include <Adafruit_CircuitPlayground.h>
#include <Arduino.h>

#define NUM_DATA_POINTS 1024

const int data[NUM_DATA_POINTS] = {
#include "10bit-sin-wave.txt"
};

void setup() {
  // disable speaker
  pinMode(11, OUTPUT);
  digitalWrite(11, LOW);
}

void loop() {
  for (int i = 0; i < NUM_DATA_POINTS; i++) {
    analogWrite(A0, data[i]);
  }
}
