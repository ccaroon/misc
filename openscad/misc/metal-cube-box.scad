difference() {
	minkowski() {
		cylinder(h = 1e-05, r = 3);
		cube(size = [22.91, 22.91, 26.9]);
	}
	translate(v = [-1.5, -1.5, 1.5]) {
		cube(size = [25.91, 25.91, 28.4]);
	}
}
