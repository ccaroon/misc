
var honda = {
  make : "Honda"
};

var Element = function () {};
Element.prototype = honda;

var car = new Element();
car.model = "Element";
car.make = "foo";

console.log(car.make);
console.log(car.model);

delete car.make;

console.log(car.make);
console.log(car.model);

delete car.make;

console.log(car.make);
console.log(car.model);

honda.make = "Toyota";

console.log(car.make);
console.log(car.model);

console.log(typeof car.make);