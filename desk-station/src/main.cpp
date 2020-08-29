#include <Arduino.h>
#include <ESP8266WiFi.h>

#include "secrets.h"
#include "sensor.h"

const char *host = "wifitest.adafruit.com";

void setup() {
  Serial.begin(115200);
  delay(100);

  if (!initSensor()) {
    Serial.println("Could not find a valid BME680 sensor, check wiring!");
    while (1)
      ;
  }

  Serial.print("Connecting to ");
  Serial.println(SSID);

  WiFi.begin(SSID, PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
}

void loop() {
  struct Measurement measurement = readSensor();
  if (!measurement.success) {
    Serial.println("Failed to perform reading :(");
    return;
  }

  Serial.print("Temperature = ");
  Serial.print(measurement.temperature);
  Serial.println(" *C");

  Serial.print("Pressure = ");
  Serial.print(measurement.pressure);
  Serial.println(" hPa");

  Serial.print("Humidity = ");
  Serial.print(measurement.humidity);
  Serial.println(" %");

  Serial.print("Gas = ");
  Serial.print(measurement.gas_resistance);
  Serial.println(" KOhms");

  Serial.print("Approx. Altitude = ");
  Serial.print(measurement.altitude);
  Serial.println(" m");

  Serial.println();
  delay(2000);
}
