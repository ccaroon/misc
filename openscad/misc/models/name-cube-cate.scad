include <lib/cubes.scad>
include <lib/units.scad>

size = 1 * inch;

hollow_cube(size, 2);

translate([-.25, size/1.5, size]) {
    color("lime") linear_extrude(height=1) {
        text("Cate", size=9, valign="top");
    }
}
