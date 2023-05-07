cm = 10;
wall = 1;

inside_w = 5.1*cm;
inside_d = 2.32*cm;

w = wall+inside_w+wall;
d = wall+inside_d+wall;
h = 1.45*cm;

usb_w = 3*wall;
usb_d = 1*cm;
usb_h = .6*cm;

difference () {
    cube([w, d, h]);

    translate([wall, wall, wall])
        cube([inside_w, inside_d, h+1]);

    translate([w-2,(d/2)-(usb_d/2),1])
        cube([usb_w,usb_d,usb_h]);
}
