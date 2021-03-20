// clang-format off
#include <lmic.h>
#include <hal/hal.h>
#include <arduino_lmic_hal_boards.h>
#include <SPI.h>
#include <U8x8lib.h>
// clang-format on

#include "secrets.h"

U8X8_SSD1306_128X64_NONAME_SW_I2C u8x8(15, 4, 16);

const unsigned TX_INTERVAL = 60;
static uint8_t mydata[] = "Hello, world!";

void os_getArtEui(uint8_t *buf) { memcpy_P(buf, APPEUI, 8); }

void os_getDevEui(uint8_t *buf) { memcpy_P(buf, DEVEUI, 8); }

void os_getDevKey(uint8_t *buf) { memcpy_P(buf, APPKEY, 16); }
static osjob_t sendjob;

void printHex2(unsigned v) {
  v &= 0xff;
  if (v < 16) {
    Serial.print('0');
  }
  Serial.print(v, HEX);
}

void do_send(osjob_t *j) {
  if (LMIC.opmode & OP_TXRXPEND) {
    Serial.println(F("OP_TXRXPEND, not sending"));
  } else {
    LMIC_setTxData2(1, mydata, sizeof(mydata) - 1, 0);
    Serial.println(F("Packet queued"));
  }
}

void onEvent(ev_t ev) {
  Serial.print(os_getTime());
  Serial.print(": ");
  switch (ev) {
  case EV_SCAN_TIMEOUT:
    Serial.println(F("EV_SCAN_TIMEOUT"));
    break;
  case EV_BEACON_FOUND:
    Serial.println(F("EV_BEACON_FOUND"));
    break;
  case EV_BEACON_MISSED:
    Serial.println(F("EV_BEACON_MISSED"));
    break;
  case EV_BEACON_TRACKED:
    Serial.println(F("EV_BEACON_TRACKED"));
    break;
  case EV_JOINING:
    Serial.println(F("EV_JOINING"));
    break;
  case EV_JOINED:
    Serial.println(F("EV_JOINED"));
    {
      u4_t netid = 0;
      devaddr_t devaddr = 0;
      uint8_t nwkKey[16];
      uint8_t artKey[16];
      LMIC_getSessionKeys(&netid, &devaddr, nwkKey, artKey);
      Serial.print("netid: ");
      Serial.println(netid, DEC);
      Serial.print("devaddr: ");
      Serial.println(devaddr, HEX);
      Serial.print("AppSKey: ");
      for (size_t i = 0; i < sizeof(artKey); ++i) {
        if (i != 0) {
          Serial.print("-");
        }
        printHex2(artKey[i]);
      }
      Serial.println("");
      Serial.print("NwkSKey: ");
      for (size_t i = 0; i < sizeof(nwkKey); ++i) {
        if (i != 0) {
          Serial.print("-");
        }
        printHex2(nwkKey[i]);
      }
      Serial.println();
    }
    // Disable link check validation (automatically enabled
    // during join, but because slow data rates change max TX
    // size, we don't use it in this example.
    LMIC_setLinkCheckMode(0);
    break;
  case EV_JOIN_FAILED:
    Serial.println(F("EV_JOIN_FAILED"));
    break;
  case EV_REJOIN_FAILED:
    Serial.println(F("EV_REJOIN_FAILED"));
    break;
  case EV_TXCOMPLETE:
    Serial.println(F("EV_TXCOMPLETE (includes waiting for RX windows)"));
    if (LMIC.txrxFlags & TXRX_ACK) {
      Serial.println(F("Received ack"));
    }
    if (LMIC.dataLen) {
      Serial.println(F("Received "));
      Serial.println(LMIC.dataLen);
      Serial.println(F(" bytes of payload"));
    }
    os_setTimedCallback(&sendjob, os_getTime() + sec2osticks(TX_INTERVAL),
                        do_send);
    break;
  case EV_LOST_TSYNC:
    Serial.println(F("EV_LOST_TSYNC"));
    break;
  case EV_RESET:
    Serial.println(F("EV_RESET"));
    break;
  case EV_RXCOMPLETE:
    Serial.println(F("EV_RXCOMPLETE"));
    break;
  case EV_LINK_DEAD:
    Serial.println(F("EV_LINK_DEAD"));
    break;
  case EV_LINK_ALIVE:
    Serial.println(F("EV_LINK_ALIVE"));
    break;
  case EV_TXSTART:
    Serial.println(F("EV_TXSTART"));
    break;
  case EV_TXCANCELED:
    Serial.println(F("EV_TXCANCELED"));
    break;
  case EV_RXSTART:
    /* do not print anything -- it wrecks timing */
    break;
  case EV_JOIN_TXCOMPLETE:
    Serial.println(F("EV_JOIN_TXCOMPLETE: no JoinAccept"));
    break;

  default:
    Serial.print(F("Unknown event: "));
    Serial.println((unsigned)ev);
    break;
  }
}

void setup() {
  u8x8.begin();
  u8x8.setFont(u8x8_font_chroma48medium8_r);
  u8x8.drawString(0, 0, "Hello world!");

  delay(5000);

  while (!Serial)
    ;
  Serial.begin(9600);
  Serial.println(F("Starting"));

  const lmic_pinmap *pPinMap = Arduino_LMIC::GetPinmap_ThisBoard();
  if (pPinMap == nullptr) {
    for (;;) {
      Serial.println(F("Unknown board"));
      delay(1000);
    }
  }

  os_init_ex(pPinMap);
  LMIC_reset();
  LMIC_setLinkCheckMode(0);
  LMIC_setDrTxpow(DR_SF7, 14);
  LMIC_selectSubBand(1);

  do_send(&sendjob);
}

void loop() { os_runloop_once(); }
