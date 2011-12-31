#!/usr/bin/env node
/**
 * To do: 
 *		
 *  	runtests: 	run tests scripts and print results
 *		profiling: 	specify CPU/memory thresholds and log when app hits  
 *		autoreload:	reload on file changes
 */


/**
 * Run the Node app
 */

var program = require('commander'),
 	exec = require('child_process').exec,
 	spawn = require('child_process').spawn,
	sys = require('sys'),
	fs = require('fs'),
	
	title = "presenter"; 


/**
 * Option parsing
 */
program
	.version('0.0.1')
	.usage('[command] <args>')
	.option('-p, --port <int>', 'Specify the listening port (default 3000)')
	.option('-d, --dbpath <path>', 'Specify the path of the db server (default: database/data)', 'database/data')
	
program
	.command('install')
	.description("-- Install the app along with all dependencies locally. Requires sudo powers --")
	.action(function() {
		exec('npm install -d', puts);
	});

program
	.command('runtests')
	.description("-- Run expresso tests. Specify a file, directory. Leave blank to run all tests in the 'test/' directory --")
	.action(function(file) {
	
		if (!file) file = 'tests/unit/';
		
		fs.stat(file, function(err, stat) {
				
			if(stat.isDirectory()) {
				
				//Open the directory, run test if it is a .js file
				fs.readdir(file, function(err, files) {
					for (i in files) {
						runtest(file+files[i]);
					}
				});

				
			}
			else if(stat.isFile()) {
				runtest(file);
			}
			
			
		});
			
	});

program
	.command('run')
	.description('-- Run the presenter app --')
	.action(appLoader);
	
	
program
	.command('debug')
	.description('-- Run the presenter in debug mode --')
	.action(function() {
		
		startMongod(function(){
		
		var debug = exec("node --debug main.js", puts),
				ni = spawn("node-inspector");
		
			putSpawns(ni);
		
		});
		
		
	});
	
program.parse(process.argv);

/**
 * Add data listeners to a given spawn and output the data
 */
function putSpawns(spawn) {
	spawn.stderr.on('data', putStream);
	spawn.stdout.on('data', putStream);
	spawn.on('exit', putStream);
}

/**
 * Checks if DB is running and starts app
 */
function appLoader() {
	startMongod(function(){
		
		startApp(program.port);
	});
	
}


/**
 * Run App
 *
 * @param	{Int}		port
 * @param	{String}	mode	
 */
function startApp(port, mode) {	
	port = (port) ? port : 3000;

	var app = require('./app').boot();

	app.listen(port, function() {
		console.log('\r\n\x1b[36mApplication started on port:\x1b[0m ' + port);
	});		

}

/**
 * Start mongod
 */

function startMongod(callback) {
	
	exec("ps -ax | grep mongod", function(err, stdout, stdin){
		
		if(err) putStream(err);
		putStream(stdin);
		
		//number of lines returned by node Stream for ps command:
		var psout = stdout.split('\n');
		
		//3 IS the magic number (ps will list all instances of mongod running: 1st - the actual grep command, 2nd - the mongod search inside childprocess.
		// This generates 3 \n chars. Anything more, bingo, we have an instance of mongod running
		if (psout.length <= 3) {
			exec("mongod --dbpath " + program.dbpath, puts);
			console.log("mongod loaded on " + program.dbpath);
			
			if (typeof callback == 'function') callback();
		}
		//mongod is already running
		else if (psout.length > 3) { 		
			log.info("Mongod is already running, here's what the process looks like:");
			putStream(stdout);
			
			if (typeof callback == 'function') callback();
		}
	});
}

/**
 * Is mongod running?
 */
function mongodStatus() {
	
}

/**
 * Run a single test
 */
function runtest(filepath){
	exec("expresso " + filepath, function(err, stdout, stdin) {
		
		if (err) return putStream(err); 
		
		console.log("Finished test: " + filepath);
		putStream(stdin);
	});
}

/**
 * Run all tests in a given directory
 */

function runAllTests(){
	
	exec("expresso tests/unit/*", function(err, stdout, stdin) {
		
	 	console.log(err);
		
		console.log("Finished running all tests in tests/unit/*");
		console.log(stdout);
		
	});
}


/**
 * Change the title of the terminal window
 */ 
function initTitle(title) {

	var x = "echo '\033]0;" + title + "\007'";
	exec(x);
	
	//And change it back to 'bash' when finished
	process.on('exit', function () {
		var x = "echo -n -e \033]0;bash\007";
		exec(x);
	});
}

//Displays an exec response
function puts(error, stdout, stderr) { 
	putStream(error); 
	putStream(stdout);
	putStream(stderr);
}

function putStream(data) {
	console.log(data);
}