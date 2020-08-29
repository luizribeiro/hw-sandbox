#include <Adafruit_BME680.h>

#include "sensor.h"

#define SEALEVELPRESSURE_HPA (1013.25)

Adafruit_BME680 bme;

bool initSensor() {
  if (!bme.begin()) {
    return false;
  }

  bme.setTemperatureOversampling(BME680_OS_8X);
  bme.setHumidityOversampling(BME680_OS_2X);
  bme.setPressureOversampling(BME680_OS_4X);
  bme.setIIRFilterSize(BME680_FILTER_SIZE_3);
  bme.setGasHeater(320, 150); // 320*C for 150 ms

  return true;
}

struct Measurement readSensor() {
  struct Measurement measurement;

  if (!bme.performReading()) {
    measurement.success = false;
    return measurement;
  }

  measurement.temperature = bme.temperature;
  measurement.pressure = bme.pressure / 100.0;
  measurement.humidity = bme.humidity;
  measurement.gas_resistance = bme.gas_resistance / 1000.0;
  measurement.altitude = bme.readAltitude(SEALEVELPRESSURE_HPA);
  measurement.success = true;

  return measurement;
}
