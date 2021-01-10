#include <Arduino.h>

void setup() {
  Serial.begin(115200);
  Serial.print("Booting... ");
  Serial.println("DONE");
}

void loop() {
  Serial.print("Sleeping for 2s... ");
  delay(2000);
  Serial.println("DONE");
}
