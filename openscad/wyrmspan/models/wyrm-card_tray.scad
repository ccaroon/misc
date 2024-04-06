$fn = 150;

union() {
	difference() {
		minkowski() {
			cylinder(h = 1e-05, r = 3);
			cube(size = [175.2, 85.75, 34.0]);
		}
		translate(v = [-1.5, -1.5, 1.5]) {
			cube(size = [58.4, 88.75, 35.5]);
		}
		translate(v = [58.4, -1.5, 1.5]) {
			cube(size = [58.4, 88.75, 35.5]);
		}
		translate(v = [118.3, -1.5, 1.5]) {
			cube(size = [58.4, 88.75, 35.5]);
		}
		translate(v = [-6.0, 45.0, 31.5]) {
			rotate(a = [90, 0, 90]) {
				cylinder(h = 186.45, r = 30.0);
			}
		}
	}
	translate(v = [29.324999999999996, -60.15, 0]) {
		difference() {
			minkowski() {
				cylinder(h = 1e-05, r = 3);
				cube(size = [115.3, 55.4, 34.0]);
			}
			translate(v = [-1.5, -1.5, 1.5]) {
				cube(size = [58.4, 58.4, 35.5]);
			}
			translate(v = [58.4, -1.5, 1.5]) {
				cube(size = [58.4, 58.4, 35.5]);
			}
			translate(v = [-6.0, 30.0, 26.5]) {
				rotate(a = [90, 0, 90]) {
					cylinder(h = 129.3, r = 25.0);
				}
			}
		}
	}
}
