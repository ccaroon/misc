include <variables.scad>

tile_height = 2;
tile_size = (3*cm) * scale;
tile_lip = .5 * cm;

// trans_x, trans_y, lip_w, lip_d
lip_params = [
    // top
    [-0, tile_size-tile_lip, tile_size-tile_lip, tile_lip],
    // right
    [tile_size-tile_lip, 0, tile_lip, tile_size-tile_lip],
    // bottom
    [0, -(tile_lip), tile_size-tile_lip, tile_lip],
    // left
    [-tile_lip, 0, tile_lip, tile_size-tile_lip],
];

tile([true,true,true,false]);


// lips - which edges should have lips
//      - top, right, bottom, left
//      - list of booleans
module tile(lips) {
    cube([tile_size-tile_lip, tile_size-tile_lip, tile_height]);

    for (num = [0:3]) {
        has_lip = lips[num];
        lip_spec = lip_params[num];
        echo(has_lip, lip_spec);
        if (has_lip) {
            echo("adding lip")
            translate([lip_spec[0], lip_spec[1], 0])
                cube([lip_spec[2], lip_spec[3], 1]);
        }
        else {
            translate([lip_spec[0], lip_spec[1], 0])
                cube([lip_spec[2], lip_spec[3], 2]);
        }
    }
}
