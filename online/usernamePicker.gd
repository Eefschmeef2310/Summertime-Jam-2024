extends Control

@onready var error_text = $VBoxContainer/ErrorText
@onready var username_feild = $VBoxContainer/UsernameFeild
@onready var submit_button = $VBoxContainer/SubmitButton
@onready var login_button = $"VBoxContainer/Login Button"

var usernameTemp : String


# Called when the node enters the scene tree for the first time.
func _ready():
	AirtableManager.CheckUsernameResponse.connect(OnUsernameCheckResponse)
	AirtableManager.NewUserResponse.connect(OnNewUserResponse)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_submit_button_pressed():
	#do a list records call filtered by the provided username, if any records are returned then make the user try again
	#otherwise create the record 
	AirtableManager.CheckUsername(username_feild.text)
	error_text.text = "checking username please wait..."
	error_text.label_settings.font_color = Color.DARK_ORANGE
	login_button.disabled = true
	

func OnUsernameCheckResponse(result : bool):
	if result == null:
		print("username check result is NULL!!!")
	elif result == false:
		error_text.text = "Username already taken! would you like to login?"
		error_text.label_settings.font_color = Color.YELLOW
		login_button.disabled = false
	else: #result must be true?
		error_text.text = "Success! Creating user..."
		error_text.label_settings.font_color = Color.MEDIUM_TURQUOISE
		usernameTemp = username_feild.text
		AirtableManager.call_deferred("NewUser",username_feild.text)
	
func OnNewUserResponse(newID : String):
	if (newID != "" || newID != null):
		AirtableManager.SetSaveData(newID, usernameTemp)
		error_text.text = "User created, ID: " + newID
		error_text.label_settings.font_color = Color.MEDIUM_TURQUOISE
		get_tree().change_scene_to_file("res://Levels/MainMenu.tscn")
	else:
		print("issue wth new user response, recevied id: " + newID)


func _on_login_button_pressed():
	AirtableManager.saveRes.userID = AirtableManager.idOfLastCheck
	get_tree().change_scene_to_file("res://Levels/saveLoader.tscn")
