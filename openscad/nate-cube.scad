inch = 25.4;

// Cube w/in a Cube
difference() {
    color("black", 0.10) cube([inch,inch,inch], center=true);
    color("red",.10) cube([inch-5,inch-5,inch-5], center=true);
}

translate([-13,10,12.5]) {
    color("red") linear_extrude(height=1) {
        text("Nate", size=9, valign="top");
    }
}

translate([-13,0,12.5]) {
    color("red") linear_extrude(height=1) {
        text("Caroon", size=5.8, valign="top");
    }
}
