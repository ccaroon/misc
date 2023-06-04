module hollow_cube(size, wall=2) {
    // Cube w/in a Cube
    difference() {
        cube([size,size,size]);

        translate([wall,wall,wall])
            cube([size-(wall*2), size-(wall*2), size-(wall*2)]);
    }
}
