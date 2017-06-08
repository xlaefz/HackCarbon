var express = require('express')
var app = express()
var router = express.Router()
var body_parser = require('body-parser')
var firebase_admin = require('firebase-admin');
var sent = require('sentiment')

// Include constants

var constants = require('./constants.js')
var const_animals = constants.animals
var const_adjectives = constants.adjectives


// Set up Firebase

var service_account = require('./serviceAccountKey.json')

firebase_admin.initializeApp({
	credential: firebase_admin.credential.cert(service_account),
	databaseURL: 'hackcarbon-masque.firebaseio.com'
})


var db = firebase_admin.database()
var ref = db.ref("users")

console.log("Getting users")

app.use(body_parser.json())

app.set('port', (process.env.PORT || 5000))

app.use('/api/v1', router)

// Convenience function

function pickRandomProperty(obj) {
    var result;
    var count = 0;
    for (var prop in obj)
        if (Math.random() < 1/++count)
           result = prop;
    return result;
}

ref.on("value", function(snapshot) {
  console.log(snapshot.val());
}, function (errorObject) {
  console.log("The read failed: " + errorObject.code);
});

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

/**
 * Requires a single parameter passed via json: requester
 * requester is the UUID of the user to be matched
 * Returns an object:
 * {
 * 	"uuid"
 * 	"name"
 * }
 */
router.post('/find_match', function(request, response) {

	var requester_uuid = request.body.requester
	var found_uuid

	if (requester_uuid == null) {
		response.json({
			"status":"error",
			"data": null,
			"message": "No requester UUID was supplied."
		})
		return
	}

	ref.on("value", function(snapshot) {
		// Pick random from snapshot object
		var table = snapshot.val()
		var chosen = null

		do {
			chosen = pickRandomProperty(table)
			console.dir('Chosen key', chosen)
		}
		while (chosen == requester_uuid)

		if (chosen != null) {
			response.json({
				"status":"success",
				"data": {
					"uuid":chosen,
					"name":table[chosen].name
				},
				"message": null
			})
		}
		else {
			response.json({
				"status":"error",
				"data": null,
				"message": "No match was found for the supplied UUID."
			})
			return
		}
	}, function (errorObject) {
		response.json({
			"status":"error",
			"data": null,
			"message": "A failure occurred while reading from Firebase."
		})
		return
	})

})

router.post('/validate_chat', function(request, response) {
	var bad_message = false

	console.log(request.body.text);
	console.dir(sent(request.body.text))
	var score = sent(request.body.text).score
	console.log("The score for this message is " + score)
	if (score <= -2) {
		bad_message = true
	}
	response.json({
		"status": "success",
		"data": {
			"bad_message": bad_message
		},
		"message": null
	})
})

app.listen(app.get('port'), function() {
	console.log("Node app is running at localhost:" + app.get('port'))
})