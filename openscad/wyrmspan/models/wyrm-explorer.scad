$fn = 150;

resize(newsize = [14.0, 18.0, 10]) {
	linear_extrude(height = 10) {
		import(file = "../resources/explorer.svg", origin = [0, 0]);
	}
}
