var mongoose  = require('mongoose'),
    fixtures  = require('./test/fixtures/card'),
    Card      = require('./lib/card'),
    i         = 0,
    card      = null,
    card_data = null;
// #############################################################################
mongoose.connect('mongodb://localhost/mtgdb');

card_data = fixtures.generate(10);

for (i = 0; i < card_data.length; i+=1) {
    card = new Card(card_data[i]);
    card.save(function (err, obj) {
        if (err) {
            console.log("Save failed: " + obj.name + ": " + err);
        }
    });
}

mongoose.disconnect();
