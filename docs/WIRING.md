# S.U.P.E.R. wiring guide

The printed rack works as passive storage with **none of this electronics installed**.

## Important electrical rule

**Do not power the 12 V fan from an Arduino GPIO pin or the Nano's 5 V pin.** The fan receives 12 V directly from the power supply. The Nano only controls the PWM lead and reads the tach lead.

The reference fan is the **Noctua NF-P12 redux-1700 PWM**. Noctua specifies it as a 120 x 120 x 25 mm, 12 V, 4-pin PWM fan with 105 mm mounting-hole spacing.

| Fan pin | Noctua wire | Connect to |
|---|---|---|
| 1 | Black | Common GND |
| 2 | Yellow | +12 V supply |
| 3 | Green | Nano D2 (tach) |
| 4 | Blue | Collector of NPN PWM transistor |

## Controller parts

- Arduino Nano R4
- 1x 2N2222 / PN2222A NPN transistor
- 1x 1 kOhm base resistor
- 1x 10 kOhm base pulldown resistor
- 1x optional 10 kOhm tach pull-up to +5 V
- 1x 4.7 kOhm DS18B20 data pull-up
- 1 to 3x DS18B20 temperature sensors
- 10x normally-open submini lever microswitches
- 12 V regulated supply, at least 1 A
- 24 to 28 AWG hookup wire
- heat-shrink tubing or insulated crimp connectors

## Power

The Nano R4 VIN input accepts the 12 V supply used by the reference build.

```text
12 V adapter +  --------------------+---------------- Fan YELLOW (+12 V)
                                    |
                                    +---------------- Nano R4 VIN

12 V adapter GND -------------------+---------------- Fan BLACK (GND)
                                    |
                                    +---------------- Nano R4 GND
                                    |
                                    +---------------- Sensor/switch GND bus
```

All grounds must be common.

If you later add a display, many LEDs, or other accessories, a small 12 V to 5 V buck converter is a good optional upgrade to reduce heat in the Nano's onboard regulator.

## Fan PWM interface

Use an **open-collector NPN stage** rather than connecting the blue PWM wire straight to the GPIO.

```text
Nano D3 ---- 1k ---- B   2N2222
                       C ---------------- Fan BLUE (PWM)
Nano GND -------------- E

10k resistor from B to GND
```

The 10 kOhm pulldown holds the transistor OFF during reset/boot. That lets the fan PWM input float HIGH through the fan's internal circuitry, giving a fail-safe full-speed command while the microcontroller is not actively driving the line.

The firmware outputs approximately **25 kHz PWM** and automatically handles the inversion caused by the NPN stage.

## Fan tach / RPM

```text
Fan GREEN (tach) ---------------- Nano D2
Fan BLACK (ground) -------------- Nano GND

Optional: 10k resistor from D2 to +5 V
```

Noctua specifies the tach output as open-collector with **two cycles per revolution**. The firmware uses that value for RPM calculation.

## Temperature sensors

All DS18B20 sensors share one 1-Wire bus.

```text
DS18B20 VDD   ---------------- +5 V
DS18B20 GND   ---------------- GND
DS18B20 DATA  ---------------- Nano D6

4.7k resistor between DATA and +5 V
```

Suggested sensor locations:

1. lower SSD bank
2. center of the SSD matrix
3. upper/rear exhaust area

The firmware uses the hottest valid sensor reading.

## SSD presence switches

Each bay uses one normally-open microswitch. One terminal of every switch shares ground; the other goes to a dedicated Nano input.

| Bay | Nano pin |
|---|---|
| 1 | D4 |
| 2 | D5 |
| 3 | D7 |
| 4 | D8 |
| 5 | D9 |
| 6 | D10 |
| 7 | D11 |
| 8 | D12 |
| 9 | D13 |
| 10 | A0 |

```text
Nano input ---- microswitch ---- GND
```

The firmware uses `INPUT_PULLUP`:

- switch open = empty bay
- switch pressed = occupied bay

The optional CAD switch carrier targets switches around **12.8 x 6.5 x 6.5 mm**. Measure your actual switches before printing ten of anything.

## SSD data cables

S.U.P.E.R. v1 is **not a USB hub**. Each SSD keeps its own front-facing USB-C port. Connect drives directly to the computer or to a suitable powered USB hub.

The Nano detects physical insertion only. It does not read the drive name, filesystem, SMART health, capacity or USB activity.
