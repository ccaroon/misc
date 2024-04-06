$fn = 150;

difference() {
	minkowski() {
		cylinder(h = 1e-05, r = 3);
		cube(size = [71.0, 52.0, 21.5]);
	}
	translate(v = [-1.5, -1.5, 1.5]) {
		cube(size = [36.25, 55.0, 23.0]);
	}
	translate(v = [36.25, -1.5, 1.5]) {
		cube(size = [36.25, 55.0, 23.0]);
	}
}
