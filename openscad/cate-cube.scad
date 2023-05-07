inch = 25.4;

// Cube w/in a Cube
difference() {
    color("blue", 0.10) cube([inch,inch,inch], center=true);
    color("red",.10) cube([inch-5,inch-5,inch-5], center=true);
}

translate([-13,5,12.5]) {
    color("green") linear_extrude(height=1) {
        text("Cate", size=9, valign="top");
    }
}
