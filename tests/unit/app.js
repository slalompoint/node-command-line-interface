var assert = require('assert'),
	path = require('path'),
	app = require('../../app');
	
/**
 * Test the asset management component
 */
 
module.exports = {
	
	// Really simple test
	'Test that the app.boot() returns something': function() {
		assert.isDefined(app.boot());
	},
};