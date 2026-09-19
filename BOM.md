# S.U.P.E.R. v1 bill of materials

## Required for passive storage

| Qty | Part | Notes |
|---:|---|---|
| 1 | Printed `SUPER_main.stl` | Holds ten Crucial X10-sized portable SSDs |
| 1 | Printed `SUPER_lid.stl` | Covers the top electronics bay even if unused |

That is all you need if you only want the storage rack.

## Smart cooling upgrade

| Qty | Part | Notes |
|---:|---|---|
| 1 | Arduino Nano R4 with headers | Main controller |
| 1 | Noctua NF-P12 redux-1700 PWM | 120 mm, 12 V, 4-pin PWM fan |
| 1 | 12 V regulated supply, >=1 A | Powers fan and Nano VIN |
| 1 | 5.5 x 2.1 mm DC jack breakout | Or another suitable keyed connector |
| 1 | 2N2222 / PN2222A NPN transistor | Open-collector PWM interface |
| 1 | 1 kOhm resistor | Nano D3 to transistor base |
| 1 | 10 kOhm resistor | Transistor base pulldown |
| 1 | 4.7 kOhm resistor | DS18B20 data pull-up |
| 1 | 10 kOhm resistor | Optional external fan tach pull-up |
| 1-3 | DS18B20 sensors | Three zones recommended |
| 10 | Normally-open submini lever microswitches | Optional bay-presence detection |
| 2 | Printed switch carriers | One per five bays |
| 1 | Printed fan grille | Optional |
| 1 roll | 24-28 AWG hookup wire | Multiple colors strongly recommended |
| as needed | Heat shrink / crimp connectors | Insulate every exposed joint |

## Optional assembly hardware

- Four M4 machine screws + nuts long enough for your chosen fan/grille stack, or the fan's included mounting screws when appropriate
- Small JST-style connectors if you want the fan, sensors, and switch carriers to unplug cleanly
- Adhesive rubber feet for the bottom of the rack
- 1 A inline fuse on the 12 V input for extra protection

## Notes

The printed switch carrier targets switches around **12.8 x 6.5 x 6.5 mm**. Buy the switches first if possible and measure them with calipers before printing the carriers.
