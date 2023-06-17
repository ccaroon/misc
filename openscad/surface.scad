// surface(file="surface.dat", convexity=5);
// $fn=100;
// surface(file="star.png", invert=false);

// -----------------------------------------------------------------------------

// Positive Profile
// rotate_extrude(angle=360, $fn=150)
    //// translate([-88,0,-25])
        //// rotate([90,0,0])
            // import("/home/ccaroon/profile.dxf");


// Negative Profile
rotate_extrude(angle=360, $fn=150)
    // translate([-88,0,-25])
        // rotate([90,0,0])
            import("/home/ccaroon/profile2.dxf");

// -----------------------------------------------------------------------------
// rotate_extrude(convexity=10, $fn=50)
// translate([1,0,0])
// circle(r=1);
