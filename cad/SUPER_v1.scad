// S.U.P.E.R. v1
// Smart USB Peripheral Enclosure Rack
// 10 Crucial X10-sized SSD bays + optional Nano R4 smart cooling.
// Units: mm.
//
// Select part:
// openscad -D 'part="main"' -o SUPER_main.stl SUPER_v1.scad
// Parts: main, lid, switch_carrier, fan_grille

$fn = 28;
part = "main";

ssd_w = 50.0;
ssd_h = 10.0;
ssd_d = 65.0;
clear_w = 1.6;
clear_h = 2.2;
clear_d = 2.0;
bay_w = ssd_w + clear_w;
bay_h = ssd_h + clear_h;
bay_d = ssd_d + clear_d;

cols = 2;
rows = 5;
outer_w = 124;
outer_h = 124;
outer_d = 80;
wall = 3;
center_div = 3;
shelf = 3;
bay_stack_h = rows*bay_h + (rows-1)*shelf;
bay_x0 = (outer_w - (2*bay_w + center_div))/2;
bay_z0 = 15;

fan_hole_spacing = 105;
fan_hole_d = 4.5;
fan_center_x = outer_w/2;
fan_center_z = outer_h/2;

elec_z0 = 96;
elec_h = 25;
elec_y0 = 5;
elec_depth = 62;
nano_pocket_l = 47.5;
nano_pocket_w = 20.0;
nano_pocket_h = 9.0;
usb_cut_w = 12;
usb_cut_h = 8;

switch_body_l = 13.2;
switch_body_w = 7.0;
switch_body_h = 7.0;
carrier_w = bay_w;
carrier_d = 9;
carrier_h = bay_stack_h;

module rounded_box(size=[10,10,10], r=2) {
    linear_extrude(height=size[2])
        offset(r=r)
            offset(delta=-r)
                square([size[0], size[1]]);
}

module bay_cut(x,z) {
    translate([x, -0.2, z]) cube([bay_w, bay_d, bay_h]);

    translate([x + bay_w/2, 5.5, z + 2.0])
        rotate([90,0,0]) cylinder(h=6, r=7.5);

    translate([x+3, bay_d-0.1, z+2])
        cube([bay_w-6, outer_d-bay_d+0.3, bay_h-4]);

    translate([x + bay_w - 7.5, bay_d-0.6, z + bay_h/2 - 2.2])
        cube([5.5, 4.0, 4.4]);
}

module rear_stop_tabs(x,z) {
    tab_w = 5;
    tab_d = 4;
    tab_h = 4;
    translate([x-0.6, bay_d-tab_d, z])
        cube([tab_w+0.6,tab_d,tab_h]);
    translate([x+bay_w-tab_w, bay_d-tab_d, z])
        cube([tab_w+0.6,tab_d,tab_h]);
    translate([x-0.6, bay_d-tab_d, z+bay_h-tab_h])
        cube([tab_w+0.6,tab_d,tab_h]);
    translate([x+bay_w-tab_w, bay_d-tab_d, z+bay_h-tab_h])
        cube([tab_w+0.6,tab_d,tab_h]);
}

module fan_mount_holes() {
    for (sx=[-1,1], sz=[-1,1]) {
        x = fan_center_x + sx*fan_hole_spacing/2;
        z = fan_center_z + sz*fan_hole_spacing/2;
        translate([x, outer_d-8, z])
            rotate([-90,0,0]) cylinder(h=10,d=fan_hole_d);
    }
}

module wire_channels() {
    for (x=[3.5, outer_w-7.5]) {
        translate([x, bay_d+1, bay_z0-1])
            cube([4, outer_d-bay_d-2, bay_stack_h+4]);
    }
    translate([3.5, bay_d+1, elec_z0-4])
        cube([outer_w-7, outer_d-bay_d-2, 4]);
}

module electronics_cut() {
    translate([12, elec_y0, elec_z0])
        cube([outer_w-24, elec_depth, elec_h+5]);

    translate([outer_w/2 - nano_pocket_l/2,
               elec_y0 + 7,
               elec_z0 - 0.2])
        cube([nano_pocket_l, nano_pocket_w, nano_pocket_h]);

    translate([-0.2, elec_y0 + 12, elec_z0 + 7])
        cube([wall+1, usb_cut_w, usb_cut_h]);

    translate([8, elec_y0+elec_depth-6, elec_z0-3])
        cube([8,8,8]);
    translate([outer_w-16, elec_y0+elec_depth-6, elec_z0-3])
        cube([8,8,8]);
}

module lid_rails_cut() {
    translate([10, elec_y0+1, elec_z0+elec_h-1.6])
        cube([outer_w-20,1.8,2.2]);
    translate([10, elec_y0+elec_depth-2.8, elec_z0+elec_h-1.6])
        cube([outer_w-20,1.8,2.2]);
}

module main_rack() {
    difference() {
        rounded_box([outer_w,outer_d,outer_h], 5);

        for (r=[0:rows-1]) for (c=[0:cols-1]) {
            x = bay_x0 + c*(bay_w+center_div);
            z = bay_z0 + r*(bay_h+shelf);
            bay_cut(x,z);
        }

        translate([2.5,10,bay_z0+4])
            cube([bay_x0-4.5, outer_d-20, bay_stack_h-8]);
        translate([bay_x0+2*bay_w+center_div+2,10,bay_z0+4])
            cube([outer_w-(bay_x0+2*bay_w+center_div)-4.5,
                  outer_d-20,
                  bay_stack_h-8]);

        translate([bay_x0+1,bay_d-0.1,bay_z0+1])
            cube([2*bay_w+center_div-2,
                  outer_d-bay_d+0.3,
                  bay_stack_h-2]);

        wire_channels();
        electronics_cut();
        lid_rails_cut();
        fan_mount_holes();
    }

    for (r=[0:rows-1]) for (c=[0:cols-1]) {
        x = bay_x0 + c*(bay_w+center_div);
        z = bay_z0 + r*(bay_h+shelf);
        rear_stop_tabs(x,z);
    }
}

module electronics_lid() {
    lid_w = outer_w-20;
    lid_d = elec_depth-2;
    lid_t = 2.2;
    difference() {
        rounded_box([lid_w,lid_d,lid_t],2);
        for (i=[0:7])
            translate([14+i*10,12,-0.2])
                cube([5,lid_d-24,lid_t+0.4]);
    }
    translate([0,0,0]) cube([lid_w,1.4,1.8]);
    translate([0,lid_d-1.4,0]) cube([lid_w,1.4,1.8]);
}

module switch_carrier() {
    difference() {
        cube([carrier_w, carrier_d, carrier_h]);
        for (r=[0:rows-1]) {
            z = r*(bay_h+shelf) + (bay_h-switch_body_h)/2;
            translate([carrier_w-switch_body_l-2, 1.0, z])
                cube([switch_body_l, switch_body_w, switch_body_h]);
            translate([carrier_w-switch_body_l-4, carrier_d-2.2, z+2.0])
                cube([switch_body_l+4, 2.5, 3.0]);
        }
        translate([2,2,2])
            cube([3,carrier_d-3,carrier_h-4]);
    }
}

module fan_grille() {
    g=124;
    t=3;
    difference() {
        rounded_box([g,g,t],5);
        translate([g/2,g/2,-0.2])
            cylinder(h=t+0.4,d=112);
        for (sx=[-1,1], sy=[-1,1]) {
            x = g/2 + sx*fan_hole_spacing/2;
            y = g/2 + sy*fan_hole_spacing/2;
            translate([x,y,-0.2])
                cylinder(h=t+0.4,d=fan_hole_d);
        }
    }
    translate([g/2-2,8,0]) cube([4,g-16,t]);
    translate([8,g/2-2,0]) cube([g-16,4,t]);
}

if (part == "main") main_rack();
else if (part == "lid") electronics_lid();
else if (part == "switch_carrier") switch_carrier();
else if (part == "fan_grille") fan_grille();
else main_rack();

// STL build trigger: v1
