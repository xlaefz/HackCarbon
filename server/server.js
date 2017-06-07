var express = require('express')
var app = express()
var router = express.Router()
var body_parser = require('body-parser')

// Include constants

var constants = require('./constants.js')
var const_animals = constants.animals
var const_adjectives = constants.adjectives

app.set('port', (process.env.PORT || 5000))

app.use('/api/v1', router)

app.get('/', function(request, response) {
	response.send('Please connect to /api/v1/{endpoint}')
})

router.get('/', function(request, response) {
	response.send('Hello World!')
})

router.get('/animal_name', function(request, response) {
	var generated_name = const_adjectives[Math.floor(Math.random()*const_adjectives.length)]
					+ ' ' + const_animals[Math.floor(Math.random()*const_animals.length)]
	response.json({
		"status": "success",
		"data": {
			"generated_name": generated_name
		},
		"message": null
	})
})

app.listen(app.get('port'), function() {
	console.log("Node app is running at localhost:" + app.get('port'))
})