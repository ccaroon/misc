include <lib/cubes.scad>
include <lib/units.scad>

size = 1 * inch;

hollow_cube(size, 2);

translate([-.25, size/1.25, size]) {
    color("red") linear_extrude(height=1) {
        text("Nate", size=9, valign="top");
    }
}

translate([-.25, size/1.25-10, size]) {
    color("red") linear_extrude(height=1) {
        text("Caroon", size=5.8, valign="top");
    }
}
