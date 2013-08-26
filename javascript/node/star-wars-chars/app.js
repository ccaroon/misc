var util = require('util');
var express = require('express');
var app = express();

// middleware - just log a message
app.use(function (req, res, next) {
    console.log("...middleware untie...");
    next();
});

// middleware - log VERB and path
app.use(function (req, res, next) {
    console.log(req.method + " " + req.path);
    next();
});

// param - parse out :name from request path
app.param('name', function (req, res, next, name) {
    req.params['name'] = name;
    next();
});

// routes
app.get('/index.html', function (req, res) {

    var body = "<h1>Star Wars Chars</h1>";
    res.setHeader('Content-type', 'text/html');
    res.setHeader('Content-length', body.length);
    res.end(body);
});

app.get('/jedi.html', function (req, res) {
    var body = '';

    var jedi = ['Mace Windu', 'Luke Skywalker', 'Kyle Katarn', 'Yoda'];
    for (var i=0; i < jedi.length; i+=1) {
        body += "<li>"+jedi[i]+"</li>"
    }

    res.send(body);
});

app.get('/sith.html', function (req, res) {
    var body = '';

    var sith = ['Darth Sidios', 'Darth Vadar', 'Darth Cadeus', 'Darth Maul'];
    for (var i=0; i < sith.length; i+=1) {
        body += "<li>"+sith[i]+"</li>"
    }

    res.send(body);
});

app.get('/:name.html', function (req, res) {
    res.send(req.params.name)
});


app.listen(8080);
console.log("Listening on port 8080.");
