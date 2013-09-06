var Card = require('../lib/card');
var should = require('should');

describe("Card", function () {

    describe("#image_name", function () {
        it('should be a valid filesystem name', function () {
            var c = new Card({name: "Doom Blade"});

            should.exist(c);
            c.should.have.property('name');
            c.image_name().should.eql('doom_blade.jpg');
        });
    });

});