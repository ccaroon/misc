var fs   = require('fs');
var http = require('http');
var fn   = 'counter.txt';

http.createServer(function (request,response) {

    if (request.url == '/count') {
        fs.readFile(fn, 'utf-8', function (error, data) {
            response.writeHead(200, {'Content-type': 'text/plain'});

            data = parseInt(data) + 1;
            fs.writeFile(fn, data);

            response.end("Counter ["+data+"]\n");
        });
    }
    else {
        response.writeHead(404);
        response.end('Not Found!\n');
    }

}).listen(8080);
