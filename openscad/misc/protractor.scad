$fn = 75;
cm = 10;

width = 15*cm;
thickness = 1;

hole_d = .5*cm;
hole_offset = .35*cm;

difference() {
    linear_extrude(height=thickness) {
        circle(d=width);
    }

    // view hole
    translate([0, hole_offset, -1])
        cylinder(d=hole_d, h=3);

    translate([-(width/2), -(width/2),-1])
        cube([width,width/2,3]);
}

line_w = .5;
line_h = .375;
line_y = (hole_offset/2)+hole_d;

rotate([0,0,-90]) {
    angle_inc = 10;
    for (angle = [10:angle_inc:180-angle_inc]) {

        rotate([0,0,angle])
            translate([-(line_w/2), line_y, thickness])
                color("red") cube([line_w, (width/2)-line_y, line_h]);
    }
}
