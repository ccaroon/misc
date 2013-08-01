var util = require('util');

var mammal = function (spec) {
    var that = {};

    that.get_name = function () {
        return spec.name;
    };

    that.says = function () {
        return spec.says || '';
    }

    return that;
}

var dog = mammal({name: "DOG", says: "Bark!"});
console.log(dog.get_name());
console.log(dog.says())

var dog = function (spec) {
    spec.says = spec.says || 'Woof!';

    var that = mammal(spec);

    that.bark = function () {
        return ('Bark, '+spec.says+', Bark.');
    };

    return (that);
};

var sam = dog({name: 'Sam'});

console.log(sam.get_name());
console.log(sam.bark());

var dakota = dog({name: 'Dakota', says: 'Grrrrr!!'});
console.log(dakota.get_name());
console.log(dakota.bark());

console.log(util.inspect(sam, {hidden: true}));