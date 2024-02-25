$fn = 150;

union() {
	cylinder(d = 30.0, h = 3.75);
	translate(v = [0, 0, 3.75]) {
		rotate_extrude($fn = 250, angle = 360) {
			import(file = "./images/queen/Queen-Profile.dxf", origin = [0, 0]);
		}
	}
	translate(v = [0, 0, 50.7]) {
		union() {
			rotate_extrude(angle = 360) {
				translate(v = [-10, 0, 0]) {
					circle(d = 2.0);
				}
			}
			difference() {
				cylinder($fn = 15, d1 = 16.5, d2 = 21.0, h = 10);
				translate(v = [0, 0, 10.5]) {
					rotate_extrude(angle = 360) {
						translate(v = [-8.5, 0, 0]) {
							circle(d = 8);
						}
					}
				}
			}
			translate(v = [0, 0, 7.75]) {
				sphere(d = 11);
			}
			translate(v = [0, 0, 14.25]) {
				sphere(d = 3);
			}
		}
	}
}
