#include <iomanip>
#include <sstream>

#include <Adafruit_EPD.h>
#include <Fonts/FreeSans9pt7b.h>
#include <Fonts/FreeSansBold9pt7b.h>

#include "sensor.h"

#define EPD_CS 15
#define EPD_DC 2
#define SRAM_CS 16
#define EPD_RESET -1
#define EPD_BUSY -1

Adafruit_IL0373 display(296, 128, EPD_DC, EPD_RESET, EPD_CS, SRAM_CS, EPD_BUSY);

void initDisplay() { display.begin(); }

std::string renderFloat(float value, const char *unit) {
  std::stringstream stream;
  stream << std::fixed << std::setprecision(2) << value;
  stream << unit;
  return stream.str();
}

void drawMeasurement(struct Measurement measurement) {
  display.clearBuffer();
  display.setTextColor(EPD_BLACK);

  display.setFont(&FreeSansBold9pt7b);
  display.setCursor(22, 24);
  display.print("Temperature:");
  display.setCursor(54, 54);
  display.print("Pressure:");
  display.setCursor(53, 84);
  display.print("Humidity:");
  display.setCursor(96, 114);
  display.print("Gas:");

  display.setFont(&FreeSans9pt7b);
  display.setCursor(150, 24);
  display.print(renderFloat(measurement.temperature, " C").c_str());
  display.setCursor(150, 54);
  display.print(renderFloat(measurement.pressure, " hPa").c_str());
  display.setCursor(150, 84);
  display.print(renderFloat(measurement.humidity, "%").c_str());
  display.setCursor(150, 114);
  display.print(renderFloat(measurement.gas_resistance, " KOhms").c_str());

  display.display();
}
