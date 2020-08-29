#include "Adafruit_EPD.h"
#include "Arduino.h"
#include "Fonts/FreeSans9pt7b.h"
#include "Fonts/FreeSansBold9pt7b.h"

#define EPD_CS 10
#define EPD_DC 9
#define SRAM_CS 8
#define EPD_RESET -1
#define EPD_BUSY -1

Adafruit_IL0373 display(296, 128, EPD_DC, EPD_RESET, EPD_CS, SRAM_CS, EPD_BUSY);

#define COLOR1 EPD_BLACK
#define COLOR2 EPD_RED

void setup() {
  Serial.begin(115200);
  Serial.println("Adafruit EPD test");

  display.begin();

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
  display.print("22.97 °C");
  display.setCursor(150, 54);
  display.print("1022.88 hPa");
  display.setCursor(150, 84);
  display.print("34.60%");
  display.setCursor(150, 114);
  display.print("158.76 KOhms");

  display.display();
}

void loop() {
  // don't do anything!
}
