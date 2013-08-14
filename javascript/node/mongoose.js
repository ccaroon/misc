var mongoose = require('mongoose');

mongoose.connect('mongodb://localhost/craigdb');

var pSchema = mongoose.Schema({
    first: String, last: String, age: Number, profession: String
});
pSchema.methods.name = function() {
    var name = this.first + " " + this.last;
    return (name);
}

// Magically maps Person model to 'people' collection in 'craigdb'
var Person = mongoose.model('Person', pSchema);

for (var i = 0; i < 500; i++) {
    var p = new Person({
        first: "Person "+i, last: "Smith "+i, age: i, profession: 'Thing '+i
    });

    p.save(function (err, obj) {
        if (err) {
            console.log("Save failed: " + obj.name + ": " + err)
        }
    });
};

mongoose.disconnect();
