$fn = 150;

difference() {
	minkowski() {
		sphere(d = 5.0);
		cylinder(h = 30.0, r1 = 20, r2 = 28.5);
	}
	translate(v = [0, 0, 30]) {
		sphere(d = 55.0);
	}
}
