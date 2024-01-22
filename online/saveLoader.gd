extends Control

# this is the scene the project should first load, it will then send the player to the menu
var headers = ["Content-Type: application/json", "Authorization: Bearer pat4TZdDHn5W4cwql.86f6516a64f037bd6545f3a08516d8f7a2ae6eb2b4c12831329800d1beea0237"]
@onready var http_request = $HTTPRequest

var nextScene = "res://Levels/Tests/InteractionTest.tscn" #menu scene goes here
var usernameScene = "res://Levels/usernamePicker.tscn" # send them back here if loading fails

# Called when the node enters the scene tree for the first time.
func _ready():
	# use user id in save file to pull the server save file
	PullSave(AirtableManager.saveRes.userID)
	#PullSave("rec3IIHKQo3AtrCkG")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_http_request_request_completed(result, response_code, headers, body):
	#update the local save file 
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(JSON.stringify(json))
	print(json.fields.get("Games Played"))
	
	AirtableManager.saveRes.username = str(json.fields.get("Username"))
	AirtableManager.saveRes.highscore = int(json.fields.get("Highscore"))
	AirtableManager.saveRes.gamesPlayed = int(json.fields.get("Games Played"))
	AirtableManager.saveRes.playtime = float(json.fields.get("Total seconds played"))
	AirtableManager.saveRes.version = int(json.fields.get("Game Version"))
	AirtableManager.Save()
	
	if(AirtableManager.saveRes.username != null):
		print("should have sent user to next scene (menu)")
		get_tree().change_scene_to_file(nextScene)
		pass
	else:
		get_tree().change_scene_to_file(usernameScene)
		
	
	pass # Replace with function body.

func PullSave(userID): #returns true if it is a new username
	var url = "https://api.airtable.com/v0/appk1cf0ZCXTATYTl/Highscores/" + userID
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error occurred in the user load request.")
		print("An error occurred in the user load request.")
	else:
		print("user load seemed to work...")
		
