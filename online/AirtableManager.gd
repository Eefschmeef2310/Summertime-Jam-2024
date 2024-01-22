## Welcome to the new and enchanced airtable manager
# this time my manager supports usernames!!!!
# during the game store and track the score and game time 
# then just call GameComplete(score, playtime)
# and the system should handle the rest
## simples!

## changes for the summertime jam!
# - username login system
# - when a player picks a username that is already taken they can choose to login instead
# - when the user starts the game (including 2nd time onward - the client will download the server save file (keeps track of highscores,, usernames, unlocked levels etc

extends HTTPRequest

var headers = ["Content-Type: application/json", "Authorization: Bearer pat4TZdDHn5W4cwql.86f6516a64f037bd6545f3a08516d8f7a2ae6eb2b4c12831329800d1beea0237"]
var usernamePickerScene = "res://Levels/usernamePicker.tscn" #yoink the user to this scene if no account is detected 
var nextScene = "res://Levels/saveLoader.tscn" #sent the user to the save loader after they create their user or login


var saveRes : SaveDataRes
var savePath : String = "user://savegame.tres"
var waitState : String = "" #emoty menas the code is not expecting anything from the server
var idOfLastCheck : String = ""

var debugNewSave = false #set to true to force a new username to be picked
var GAME_VERSION = 1 #increment this for leaderboard resets!

signal response(string)
signal noUserSet
signal CheckUsernameResponse(result : bool)
signal NewUserResponse(newID : String)

# Called when the node enters the scene tree for the first time.
func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	request_completed.connect(_on_request_completed)
	if (FileAccess.file_exists(savePath)||debugNewSave):
		Load()
		get_tree().change_scene_to_file(nextScene)
	else:
		#create a new save file
		saveRes = SaveDataRes.new()
		saveRes.version = GAME_VERSION
		noUserSet.emit()
		get_tree().change_scene_to_file(usernamePickerScene)
	#load save data - if no save data then make user pick name
	
	pass # Replace with function body.

func SetSaveData(userID : String, username : String): #connect with signal(?) for when username has been set or changed
	saveRes.userID = userID
	saveRes.username = username
	saveRes.version = GAME_VERSION
	Save()

func CheckUsername(username): #returns true if it is a new username
	var url = "https://api.airtable.com/v0/appk1cf0ZCXTATYTl/Highscores?fields%5B%5D=Username&filterByFormula=%7BUsername%7D+%3D+'"+username+"'&maxRecords=1&pageSize=1"
	var error = request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error occurred in the username lookup request.")
		print("An error occurred in the username lookup request.")
	else:
		print("username lookup seemed to work...")
		waitState = "CheckUsername"

func NewUser(username):
	#does not check usernaem (use CheckUsername())
	#this function just makes a blank user record and returns the record id
	print("updating a record")
	var url = "https://api.airtable.com/v0/appk1cf0ZCXTATYTl/Highscores"
	var data = {"records": [
	{
	  "fields": {
		"Username" : String(username),
		"Highscore": 0, 
		"Games Played": 0,
		"Total seconds played": 0.0,
		"Game Version" : GAME_VERSION
	  }
	}]}
	var error = request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(data))
	if error != OK:
		push_error("An error occurred in the new user request.")
		print("An error occurred in the new user request.")
	else:
		print("new user request Sent! awaiting response...")
		waitState = "NewUser"
		print(waitState)

func GameComplete(score : int, playtime : float):
	saveRes.gamesPlayed += 1
	saveRes.playtime += playtime
	if (score > saveRes.highscore):
		saveRes.highscore = score
	if(saveRes.version == GAME_VERSION): #dont save or upload if player has rollback their save
		Save()
		UploadData(saveRes.userID, saveRes.username, saveRes.highscore, saveRes.gamesPlayed, saveRes.playtime, saveRes.version)
	else:
		print("OLD VERSION - DID NOT SAVE OR UPLOAD")

func UploadData(userID : String, username : String, highscore : int, gamesPlayed : int, playtime : float, version : int):
	print("updating a record")
	var url = "https://api.airtable.com/v0/appk1cf0ZCXTATYTl/Highscores/" + str(userID)
	var data = {
	  "fields": {
		#"Username" : String(username),
		"Highscore": int(highscore), 
		"Games Played": int(gamesPlayed),
		"Total seconds played": float(playtime),
		"Game Version": int(version)
	  }
	}
	var error = request(url, headers, HTTPClient.METHOD_PATCH, JSON.stringify(data))
	if error != OK:
		push_error("An error occurred in the HTTP request.")
		print("HTTP Error D=")
	else:
		print("Run Data Sent!")
	return true

func Save():
	ResourceSaver.save(saveRes, savePath)
	
func Load():
	var specialUpload = false
	saveRes = ResourceLoader.load(savePath) as SaveDataRes
	print("loaded a save file:")
	print("id: " + saveRes.userID + ", username: " + saveRes.username)
	if(saveRes.version < GAME_VERSION):
		print("old save detected, resseting highscore")
		saveRes.highscore = 0 #reset highscore for new version
		saveRes.version = GAME_VERSION
		specialUpload = true
	else:
		print("Save Version: " + str(saveRes.version))
	
	
	if specialUpload:
		Save()
		UploadData(saveRes.userID, saveRes.username, saveRes.highscore, saveRes.gamesPlayed, saveRes.playtime, saveRes.version)

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(JSON.stringify(json))
	response.emit(JSON.stringify(json))
	print(waitState)
	if(waitState == "CheckUsername"):
		#print("amount of records: " + str(json.records.size()))
		if(json.records.size() > 0):
			print("username is NOT new")
			idOfLastCheck = json.records[0].id
			CheckUsernameResponse.emit(false)
		else:
			print("username is NEW")
			CheckUsernameResponse.emit(true)
		
	if(waitState == "NewUser"):
		print(json.records[0].id)
		NewUserResponse.emit(json.records[0].id)
		
	waitState = ""
	#print(json.records[0].id) works with getting the id of things already in the base
