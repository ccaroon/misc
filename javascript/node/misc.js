
function hello_f () {
    var hello = "planet earth";
    console.log("=====> misc.js #4 --> func("+hello+")");
}

hello_f();

if (1) {
    var hello = 'world';
    console.log("=====> misc.js #4 --> IN IF ["+hello+"]");
}


console.log("=====> misc.js #8 --> OUT IF ["+hello+"]");

var r1 = /^X/;
var r2 = /^X/;

if (r1 == r2) {
    console.log("=====> misc.js #21 --> r1 == r2");
}

if (r1 === r2) {
    console.log("=====> misc.js #25 --> r1 === r2");
}

console.log("=====> misc.js #28 --> ["+(typeof r1)+"]");

var x = undefined;
var y = null;

console.log("=====> misc.js #33 --> ["+x+"] ["+y+"]");
console.log("=====> misc.js #33 --> ["+typeof x+"] ["+typeof y+"]");

if (x == y) {
    console.log("=====> misc.js #37 --> x == y");
}

if (x === y) {
    console.log("=====> misc.js #41 --> x === y ");
}

if (x == undefined) {
    console.log("=====> misc.js #45 --> x == undefined");
}

if (x === undefined ) {
    console.log("=====> misc.js #49 --> x === undefined");
}

if (y == null) {
    console.log("=====> misc.js #53 --> y == null");
}

if (y === null) {
    console.log("=====> misc.js #57 --> y === null");
}

if (x == null) {
    console.log("=====> misc.js #61 --> x == null");
}

if (y == undefined) {
    console.log("=====> misc.js #65 --> y == undefined");
}



var str = "hello";
var str2 = str;
var str3 = "hello";

if (str === str2) {
    console.log("=====> misc.js #74 --> str === str2");
}

if (str === str3) {
    console.log("=====> misc.js #79 --> str === str3");
}
