/*
  S.U.P.E.R. Controller
  Smart USB Peripheral Enclosure Rack

  Target: Arduino Nano R4
  Fan: 4-wire 12 V PWM PC fan
  Sensors: up to 3 DS18B20 temperature sensors on one 1-Wire bus
  Bay detection: 10 normally-open microswitches, active LOW with INPUT_PULLUP

  IMPORTANT:
  - The fan's 12 V power does NOT come from the Nano.
  - The Nano controls the fan PWM lead through an NPN open-collector stage.
  - Fan and Nano grounds MUST be common.
  - A 10k base pulldown keeps the transistor OFF while the Nano boots,
    so the fan PWM input floats HIGH and defaults to full speed.
*/

#include <Arduino.h>
#include <OneWire.h>
#include <DallasTemperature.h>
#include "pwm.h"

constexpr uint8_t FAN_PWM_PIN  = D3;
constexpr uint8_t FAN_TACH_PIN = D2;
constexpr uint8_t TEMP_PIN     = D6;

const uint8_t BAY_PINS[10] = {
  D4, D5, D7, D8, D9,
  D10, D11, D12, D13, A0
};

constexpr float FAN_PWM_FREQUENCY_HZ = 25000.0f;
constexpr uint8_t TACH_PULSES_PER_REV = 2;
constexpr uint16_t RPM_SAMPLE_MS = 1000;
constexpr bool FAILSAFE_FULL_SPEED_ON_TEMP_ERROR = true;

constexpr float T0 = 35.0f;
constexpr float T1 = 40.0f;
constexpr float T2 = 45.0f;
constexpr float T3 = 50.0f;

OneWire oneWire(TEMP_PIN);
DallasTemperature tempBus(&oneWire);
PwmOut fanPwm(FAN_PWM_PIN);

volatile uint32_t tachPulses = 0;
uint32_t lastRpmSample = 0;
uint32_t lastStatusPrint = 0;
uint16_t currentRpm = 0;
float currentFanPercent = 100.0f;
float currentMaxTempC = NAN;
uint8_t currentOccupied = 0;

void tachISR() {
  tachPulses++;
}

uint8_t countOccupiedBays() {
  uint8_t count = 0;
  for (uint8_t i = 0; i < 10; ++i) {
    if (digitalRead(BAY_PINS[i]) == LOW) count++;
  }
  return count;
}

float readMaxTemperatureC() {
  tempBus.requestTemperatures();
  const uint8_t count = tempBus.getDeviceCount();
  if (count == 0) return NAN;

  float maxTemp = -1000.0f;
  bool foundValid = false;
  const uint8_t n = (count < 3) ? count : 3;

  for (uint8_t i = 0; i < n; ++i) {
    const float t = tempBus.getTempCByIndex(i);
    if (t != DEVICE_DISCONNECTED_C && t > -55.0f && t < 125.0f) {
      if (t > maxTemp) maxTemp = t;
      foundValid = true;
    }
  }

  return foundValid ? maxTemp : NAN;
}

float fanCurve(float tempC) {
  if (isnan(tempC)) {
    return FAILSAFE_FULL_SPEED_ON_TEMP_ERROR ? 100.0f
                                             : (currentOccupied ? 35.0f : 0.0f);
  }

  if (tempC <= T0) return 0.0f;
  if (tempC <= T1) return 25.0f;
  if (tempC <= T2) return 50.0f;
  if (tempC <= T3) return 75.0f;
  return 100.0f;
}

void setFanPercent(float requestedPercent) {
  requestedPercent = constrain(requestedPercent, 0.0f, 100.0f);

  // NPN stage inverts the logic:
  // Nano HIGH -> transistor ON -> fan PWM lead LOW.
  // Nano LOW  -> transistor OFF -> fan internal pull-up HIGH.
  const float transistorDuty = 100.0f - requestedPercent;
  fanPwm.pulse_perc(transistorDuty);
  currentFanPercent = requestedPercent;
}

void updateRpm() {
  const uint32_t now = millis();
  if (now - lastRpmSample < RPM_SAMPLE_MS) return;

  noInterrupts();
  const uint32_t pulses = tachPulses;
  tachPulses = 0;
  interrupts();

  const float elapsedSeconds = (now - lastRpmSample) / 1000.0f;
  lastRpmSample = now;

  if (elapsedSeconds > 0.0f) {
    currentRpm = (uint16_t)((pulses * 60.0f) /
                            (TACH_PULSES_PER_REV * elapsedSeconds));
  }
}

void printStatus() {
  const uint32_t now = millis();
  if (now - lastStatusPrint < 2000) return;
  lastStatusPrint = now;

  Serial.println(F("\n--- S.U.P.E.R. STATUS ---"));
  Serial.print(F("Bays occupied: "));
  Serial.print(currentOccupied);
  Serial.println(F(" / 10"));

  Serial.print(F("Bay map: "));
  for (uint8_t i = 0; i < 10; ++i) {
    Serial.print(digitalRead(BAY_PINS[i]) == LOW ? F("[X]") : F("[ ]"));
  }
  Serial.println();

  Serial.print(F("Max temperature: "));
  if (isnan(currentMaxTempC)) {
    Serial.println(F("SENSOR ERROR"));
  } else {
    Serial.print(currentMaxTempC, 1);
    Serial.println(F(" C"));
  }

  Serial.print(F("Fan command: "));
  Serial.print(currentFanPercent, 0);
  Serial.println(F(" %"));

  Serial.print(F("Fan RPM: "));
  Serial.println(currentRpm);
}

void setup() {
  Serial.begin(115200);
  delay(300);
  Serial.println(F("S.U.P.E.R. controller starting..."));

  for (uint8_t i = 0; i < 10; ++i) {
    pinMode(BAY_PINS[i], INPUT_PULLUP);
  }

  pinMode(FAN_TACH_PIN, INPUT_PULLUP);
  attachInterrupt(digitalPinToInterrupt(FAN_TACH_PIN), tachISR, FALLING);

  tempBus.begin();
  tempBus.setResolution(10);

  if (!fanPwm.begin(FAN_PWM_FREQUENCY_HZ, 0.0f)) {
    Serial.println(F("ERROR: Could not start fan PWM timer."));
  }

  currentOccupied = countOccupiedBays();
  currentMaxTempC = readMaxTemperatureC();
  setFanPercent(fanCurve(currentMaxTempC));

  lastRpmSample = millis();
}

void loop() {
  currentOccupied = countOccupiedBays();
  currentMaxTempC = readMaxTemperatureC();
  setFanPercent(fanCurve(currentMaxTempC));

  updateRpm();
  printStatus();

  delay(500);
}
