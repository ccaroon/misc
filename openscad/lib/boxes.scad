// Create a Box with...
// width - inside width of the box
// height - height of the box
// wall - thickness of the walls
module box(width, length, height, wall=1) {
    difference () {
        cube([wall+width+wall, wall+length+wall, height]);

        translate([wall, wall, wall])
            cube([width, length, height]);
    }
}
