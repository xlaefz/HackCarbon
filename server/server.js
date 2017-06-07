var express = require('express')
var app = express()
var router = express.Router()
var body_parser = require('body-parser')

app.set('port', (process.env.PORT || 5000))

app.use('/api/v1', router)

app.get('/', function(request, response) {
	response.send('Please connect to /api/v1/{endpoint}')
})

router.get('/', function(request, response) {
	response.send('Hello World!')
})

router.get('/animal_name', function(request, response) {
	var animals = ['cat', 'dog', 'mouse']
	var adjectives = ['silly', 'big', 'little']	
	var generated = adjectives[Math.floor(Math.random()*adjectives.length)] + ' ' + animals[Math.floor(Math.random()*animals.length)]
	response.send(generated)
})

app.listen(app.get('port'), function() {
	console.log("Node app is running at localhost:" + app.get('port'))
})