include <variables.scad>

width = 3*cm * scale;
depth = 3*cm * scale;
height = 2;

edge_depth = .5*cm;
edge_height = 1;


tile([true, false, false, false]);

translate([width + 1*cm, 0, 0])
    tile([true, true, false, false]);

translate([0, depth + 1*cm, 0])
    tile([true, true, true, false]);

translate([width + 1*cm, depth + 1*cm, 0])
    tile([true, true, true, true]);

module tile(edges) {
    offset = 0.1;

    difference () {
        cube([width, depth, height]);

        // top
        if (edges[0]) {
            translate([-offset, depth - edge_depth, 1])
                cube([offset+width+offset, edge_depth+offset, 1+offset]);
        }

        // right
        if (edges[1]) {
            translate([width-edge_depth, -offset, 1])
                cube([edge_depth+offset, offset+width+offset, 1+offset]);
        }

        // bottom
        if (edges[2]) {
            translate([-offset, -offset, 1])
                cube([offset+width+offset, edge_depth+offset, 1+offset]);
        }

        // left
        if (edges[3]) {
            translate([-offset, -offset, 1])
                cube([edge_depth+offset, offset+width+offset, 1+offset]);
        }
    }
}
