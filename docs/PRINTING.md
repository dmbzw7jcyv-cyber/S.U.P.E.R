# Printing and assembly

## Files

- `stl/SUPER_main.stl` - main 10-bay rack and rear fan mount
- `stl/SUPER_lid.stl` - electronics-compartment lid
- `stl/SUPER_switch_carrier.stl` - optional five-switch carrier; print two
- `stl/SUPER_fan_grille.stl` - optional rear fan guard
- `cad/SUPER_v1.scad` - editable source

## Main dimensions

The body is approximately **124 x 124 x 80 mm**. A 25 mm-thick 120 mm fan mounted on the rear brings total depth to about **105 mm**.

The current SSD cavities use an approximately **65 x 50 x 10 mm** X10 envelope plus print and airflow clearance. Verify against your own drive before a long print.

## Suggested settings

- Material: PETG preferred; PLA+ is fine for ordinary indoor temperatures
- Layer height: 0.20 mm
- Walls/perimeters: 4
- Top/bottom layers: 4 or 5
- Infill: 15 to 25%
- Nozzle: 0.4 mm

For the main body, orient the model so the **front face is on the build plate**. This makes the long SSD cavities build vertically rather than requiring giant horizontal bridges.

The smaller parts can print flat on their largest face.

## Fit-test first

Printers vary. Before committing to the full rack, make a small one-bay test or crop the model in your slicer. An X10 should slide in without force but should not rattle dramatically.

If your printer runs tight, increase `clear_w` and `clear_h` in `cad/SUPER_v1.scad` by about 0.2 to 0.4 mm.

## Fan orientation

Mount the fan at the rear as **exhaust**. It should pull room air through the open front/side passages, across the SSDs, and out the back.

The model uses a standard **105 x 105 mm** 120 mm fan mounting pattern.

## Electronics bay

The top service compartment is separate from the SSD tunnels and includes:

- Nano-R4-sized pocket
- side USB-C programming opening
- wiring pass-throughs to the rear cable spines
- removable vented lid

The rack still works with this compartment totally empty.

## Presence sensors

Print **two** switch carriers if you want smart bay detection. Each holds five switches.

Microswitch dimensions vary by manufacturer. If yours do not fit, change only the `switch_body_*` parameters in the SCAD and re-export the carrier.

## Fan grille

The rear grille is optional. If installed, use fasteners long enough for your fan/grille arrangement but never allow screw tips to contact the blades.
