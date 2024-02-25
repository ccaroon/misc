$fn = 150;

difference() {
	minkowski() {
		cylinder(h = 1e-05, r = 3);
		cube(size = [108.5, 71.0, 26.5]);
	}
	translate(v = [-1.5, -1.5, 1.5]) {
		cube(size = [55.0, 36.25, 28.0]);
	}
	translate(v = [55.0, -1.5, 1.5]) {
		cube(size = [55.0, 36.25, 28.0]);
	}
	translate(v = [-1.5, 36.25, 1.5]) {
		cube(size = [55.0, 36.25, 28.0]);
	}
	translate(v = [55.0, 36.25, 1.5]) {
		cube(size = [55.0, 36.25, 28.0]);
	}
}
