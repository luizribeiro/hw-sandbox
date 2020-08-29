#ifndef _SENSOR_H
#define _SENSOR_H

struct Measurement {
  bool success;

  float temperature;
  float pressure;
  float humidity;
  float gas_resistance;
  float altitude;
};

bool initSensor();
struct Measurement readSensor();

#endif
