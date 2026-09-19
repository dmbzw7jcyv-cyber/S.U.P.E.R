# S.U.P.E.R.

## Smart USB Peripheral Enclosure Rack

S.U.P.E.R. is a 3D-printable rack for **ten Crucial X10-sized portable SSDs**. It works as plain passive storage with zero electronics, then upgrades into a temperature-controlled rack using an Arduino Nano R4, a 120 mm PWM fan, temperature sensors, fan RPM monitoring, and optional physical SSD-presence switches.

Every SSD sits horizontally with its **USB-C port facing forward**, so a drive can remain in the rack while connected.

## v1 features

- 10 horizontal SSD bays in a 2 x 5 layout
- front-facing USB-C access
- finger-access openings
- rear mount for a standard 120 mm fan
- large airflow paths around the SSD matrix
- upper service compartment sized for an Arduino Nano R4
- hidden wiring channels
- optional removable microswitch carriers for bay detection
- optional rear fan grille
- removable electronics lid
- fully functional passive mode with no electronics installed

## Approximate size

The printed main body is about **124 x 124 x 80 mm**. A standard 25 mm-thick rear fan brings total depth to about **105 mm**.

## Reference electronics

- Arduino Nano R4
- Noctua NF-P12 redux-1700 PWM
- 1 to 3 DS18B20 temperature sensors
- 10 normally-open submini lever microswitches
- regulated 12 V power supply

## Repository layout

```text
S.U.P.E.R/
├── README.md
├── BOM.md
├── cad/
│   └── SUPER_v1.scad
├── stl/
│   ├── SUPER_main.stl
│   ├── SUPER_lid.stl
│   ├── SUPER_switch_carrier.stl
│   └── SUPER_fan_grille.stl
├── firmware/
│   └── SUPER_Controller/
│       └── SUPER_Controller.ino
└── docs/
    ├── WIRING.md
    └── PRINTING.md
```

The GitHub Action in `.github/workflows/build-stls.yml` regenerates the STL files from the OpenSCAD source.

## Build order

1. Print the main rack and lid.
2. Test a real X10 in several bays before installing electronics.
3. Mount the 120 mm fan on the rear as exhaust.
4. Install the Nano R4 in the upper service bay.
5. Wire fan power, PWM and tach according to `docs/WIRING.md`.
6. Add DS18B20 sensors and the required 4.7 kOhm pull-up.
7. If wanted, print two switch carriers and install the ten presence switches.
8. In Arduino IDE Library Manager, install **OneWire** and **DallasTemperature**.
9. Open `firmware/SUPER_Controller/SUPER_Controller.ino`.
10. Select **Arduino Nano R4**, compile and upload.
11. Open Serial Monitor at **115200 baud**.

## Default cooling curve

| Hottest sensor | Fan command |
|---|---:|
| <= 35 C | 0% |
| 35-40 C | 25% |
| 40-45 C | 50% |
| 45-50 C | 75% |
| > 50 C | 100% |

If temperature sensing fails, v1 commands **100% fan speed** as a fail-safe.

These are project defaults, not manufacturer thermal limits. Tune them only after testing your own enclosure, room temperature and workloads.

## Fan-control design

The fan is powered directly from the 12 V supply. **Do not power the fan from a Nano GPIO pin.** Nano D3 controls the blue PWM lead through a 2N2222/PN2222A NPN transistor used as an open-collector driver. The firmware generates a 25 kHz PWM waveform using the Nano R4 Renesas PWM API.

The fan green tach lead is read on D2 so the controller can report RPM.

## Bay detection

Each bay can press a normally-open microswitch when a drive is fully inserted. The switches share a ground bus and use the Nano's internal pull-ups.

This detects **physical presence only**. v1 does not inspect the SSD filesystem, SMART data, drive name, capacity or USB activity.

## Passive mode

Don't want to wire anything yet? Print the main rack and lid and use it immediately. The fan, Nano, temperature sensors and bay switches are optional upgrades and do not form part of the structural SSD slots.

## CAD

The editable source is `cad/SUPER_v1.scad`.

```bash
openscad -D 'part="main"' -o SUPER_main.stl cad/SUPER_v1.scad
openscad -D 'part="lid"' -o SUPER_lid.stl cad/SUPER_v1.scad
openscad -D 'part="switch_carrier"' -o SUPER_switch_carrier.stl cad/SUPER_v1.scad
openscad -D 'part="fan_grille"' -o SUPER_fan_grille.stl cad/SUPER_v1.scad
```

## Hardware references

- Arduino Nano R4: https://docs.arduino.cc/hardware/nano-r4/
- Noctua NF-P12 redux-1700 PWM: https://www.noctua.at/en/products/nf-p12-redux-1700-pwm
- Noctua PWM microcontroller guide: https://www.noctua.at/en/support/faqs/microcontroller-guide-pwm-setup-and-rpm-monitoring
- Crucial X10: https://www.crucial.com/ssd/x10

## Prototype warning

**v1 is a prototype design.** Measure your exact SSDs, switches, connectors and printed fit before assembling the complete electronics package. Insulate all connections, verify polarity with a multimeter, confirm the fan fail-safe works, and do not leave an early prototype powered unattended.
