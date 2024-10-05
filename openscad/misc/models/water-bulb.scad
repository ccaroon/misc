$fn = 150;

union() {
	difference() {
		sphere(d = 76.19999999999999);
		sphere(d = 74.19999999999999);
		translate(v = [0, 0, 36.099999999999994]) {
			cylinder(d = 12.5, h = 2);
		}
	}
	translate(v = [0, 0, 36.099999999999994]) {
		difference() {
			cylinder(d1 = 12.5, d2 = 9.375, h = 101.6);
			translate(v = [0, 0, -3.0]) {
				cylinder(d1 = 10.5, d2 = 7.375, h = 107.6);
			}
		}
	}
}
