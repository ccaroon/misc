var util = require('util');
var mysql = require('mysql');
var conn = mysql.createConnection({
    'user': 'root',
    'password': '',
    'database': 'metiisto_devel'
});

// conn.connect();
// .query() causes implicit connect()
conn.query('select * from tags', function (error, rows) {
    if (error) throw error;

    for (i = 0; i < rows.length; i++) {
        console.log("Id -> ["+rows[i].id+"] | Name -> ["+rows[i].name+"]");
    }

});

conn.end();
