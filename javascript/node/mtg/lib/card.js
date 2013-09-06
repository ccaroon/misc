var mongoose = require('mongoose');
var schema   = mongoose.Schema({
    name: String,
    mana_cost: String,
    main_type: String,
    sub_type: String,
    foil: Boolean,
    rarity: String,
    count: Number
});

schema.methods.image_name = function() {
    var image_name = this.name.replace(/[^a-zA-Z0-9_]/, '_').toLowerCase() + '.jpg';
    return (image_name);
}

var Card = mongoose.model('Card', schema);
module.exports = Card;
