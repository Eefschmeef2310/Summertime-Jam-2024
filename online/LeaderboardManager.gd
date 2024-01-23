extends ScrollContainer

var headers = ["Content-Type: application/json", "Authorization: Bearer patmff0RoQNsaXAu4.c266daf41f901816c2993c075c457a3fee210eeb7d4cf0b2593c575261633776"]
@export var numberOfRecords = 100 # MAX 100 supported

@export var entryPrefab : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	#destroy placeholder entries 
	
	
	#do a call to airtable requesting top x amount of records sorted by score
	GetLeaderboard(numberOfRecords)
	
	#create a leaderboardEntry for every returned result 
	#	as ur doing that, set their values AND the positon too!
	#	 bonus: if its the current user, then highlight it
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func GetLeaderboard(amount): #returns true if it is a new username
	var url = "https://api.airtable.com/v0/appFZUpd22afr8fEJ/Highscores?fields%5B%5D=Username&fields%5B%5D=Highscore&filterByFormula=AND(NOT(%7BHighscore%7D+%3D+0)%2C%7BGame+Version%7D+%3D+"+ str(AirtableManager.GAME_VERSION) +")&maxRecords="+str(numberOfRecords)+"&sort%5B0%5D%5Bfield%5D=Highscore&sort%5B0%5D%5Bdirection%5D=desc"
	var error = $LeaderboardRequest.request(url, headers, HTTPClient.METHOD_GET)
	if error != OK:
		push_error("An error occurred in the leaderboard get request.")
		print("An error occurred in the leaderboard get request.")
	else:
		print("leaderbard get seemed to work...")

func _on_leaderboard_request_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(JSON.stringify(json))
	$LoadingLabel.visible = false
	for i : int in range(json.records.size()):
		print(json.records[i].fields.Username)
		var newEntry = entryPrefab.instantiate()
		newEntry.SetEntryData(i+1, json.records[i].fields.Username, json.records[i].fields.Highscore)
		if(json.records[i].id == AirtableManager.saveRes.userID):
			newEntry.SetLocalEntry()
		$MarginContainer/EntryContainer.add_child(newEntry)
		pass
