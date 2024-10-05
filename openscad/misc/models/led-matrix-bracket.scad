$fn = 75;

difference() {
	hull() {
		cylinder(d = 10, h = 2);
		translate(v = [20, 0, 0]) {
			cylinder(d = 10, h = 2);
		}
	}
	translate(v = [0, 0, -1]) {
		cylinder(d = 3.25, h = 4);
	}
	translate(v = [20, 0, -1]) {
		cylinder(d = 3.25, h = 4);
	}
}
