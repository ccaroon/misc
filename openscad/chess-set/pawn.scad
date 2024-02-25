$fn = 150;

union() {
	cylinder(d = 26.0, h = 3.75);
	translate(v = [0, 0, 3.75]) {
		union() {
			cube(center = true, size = [15.6, 15.6, 5]);
			cylinder(d1 = 13.0, d2 = 6.5, h = 24.35);
		}
	}
	translate(v = [0, 0, 28.1]) {
		sphere(d = 15.0);
	}
}
