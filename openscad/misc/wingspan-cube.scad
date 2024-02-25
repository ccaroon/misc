
count = 8;
size = 8;

for (i=[1:count]) {
    translate([(i*size)+(i*2),0,0])
        cube([size, size, size]);
}
