extends Control

var headers = ["Content-Type: application/json", "Authorization: Bearer pat4TZdDHn5W4cwql.86f6516a64f037bd6545f3a08516d8f7a2ae6eb2b4c12831329800d1beea0237"]
@onready var http_request = $HTTPRequest
@onready var label = $MarginContainer/VBoxContainer/Label
@onready var retry_button = $MarginContainer/VBoxContainer/RetryButton
@onready var create_new_button = $MarginContainer/VBoxContainer/CreateNewButton
@onready var offline_mode = $MarginContainer/VBoxContainer/OfflineMode

func _ready():
	# use user id in save file to pull the server save file
	PullSave(AirtableManager.saveRes.userID)

func _on_http_request_request_completed(result, response_code, headers, body):
	#update the local save file 
	var json = JSON.parse_string(body.get_string_from_utf8())
	#print(JSON.stringify(json))
	
	#check if error, if there is show the buttons and let the user decid what to do
	if json.has("error"):
		label.text = "An error occured while downloading your save :("
		label.label_settings.font_color = Color.CRIMSON
		retry_button.visible = true
		create_new_button.visible = true
		offline_mode.visible = true
	else:
		#load save data from server response 
		AirtableManager.saveRes.username = str(json.fields.get("Username"))
		AirtableManager.saveRes.highscore = int(json.fields.get("Highscore"))
		AirtableManager.saveRes.gamesPlayed = int(json.fields.get("Games Played"))
		AirtableManager.saveRes.playtime = float(json.fields.get("Total seconds played"))
		AirtableManager.saveRes.version = int(json.fields.get("Game Version"))
		AirtableManager.Save()
		
		#if it was able to find and load their save, send them to the menu scene otherwise get them to pick a new name TODO make it show an ewrror instead 
		if(AirtableManager.saveRes.username != null):
			print("should have sent user to next scene (menu)")
			get_tree().change_scene_to_file(AirtableManager.menuSceme)
			pass
		else:
			get_tree().change_scene_to_file(AirtableManager.usernamePickerScene)

func PullSave(userID): 
	var url = "https://api.airtable.com/v0/appk1cf0ZCXTATYTl/Highscores/" + userID
	var error = http_request.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error occurred in the user load request.")
		print("An error occurred in the user load request.")
	else:
		print("user load seemed to work...")

func _on_create_new_button_pressed():
	get_tree().change_scene_to_file(AirtableManager.usernamePickerScene)

func _on_retry_button_pressed():
	label.label_settings.font_color = Color.WHITE
	retry_button.visible = false
	create_new_button.visible = false
	offline_mode.visible = false
	get_tree().change_scene_to_file(AirtableManager.saveLoaderScene)

func _on_offline_mode_pressed():
	AirtableManager.offlineModeActive = true
	get_tree().change_scene_to_file(AirtableManager.menuSceme)
