$fn=150;
cm = 10;


difference () {
    translate([0,0,1.5*cm])
        sphere(d=3.0*cm);

    translate([0,0,0])
        cylinder(d=1.5*cm, h=1*cm);
}
