express = require('express');

exports.boot = function() {
	var app = express.createServer();
	
	app.get('/', function(req, res){
	    res.send('Hello World');
	});
	
	return app;
}
