var Card     = require('../lib/card'),
    should   = require('should'),
    fixtures = require('./fixtures/card');

describe("Card", function () {

    describe("basics", function () {

        it("should support basic attributes", function() {
            var data = fixtures.armada_wurm,
                c    = new Card(data);

            should.exist(c);

            for (p in data) {
                c.should.have.property(p, data[p]);
            }
        });

    });

    describe("#image_name", function () {

        it('should be a valid image file name', function () {
            var c = new Card(fixtures.armada_wurm);

            should.exist(c);
            c.should.have.property('name');
            c.image_name().should.eql('armada_wurm.jpg');
        });

    });

});
