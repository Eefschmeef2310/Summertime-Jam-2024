extends PanelContainer

func SetEntryData(position : int, name : String, score : int):
	$Columns/Position.text = str(position)
	$Columns/Username.text = name 
	$Columns/Score.text = str(score)

func SetLocalEntry():
	var newSettings = $Columns/Username.label_settings.duplicate()
	newSettings.font_color = Color.GOLDENROD
	$Columns/Username.label_settings = newSettings
	$Columns/Position.label_settings = newSettings
	$Columns/Score.label_settings = newSettings
	
