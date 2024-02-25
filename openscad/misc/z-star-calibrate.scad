
size = 25;
y_pos = -4.5 * size;

translate([0,y_pos,0]) {
    scale([size,size,1]) {
        linear_extrude(height=1) {
            text("*", size=10);
        }
    }
}
