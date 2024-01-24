extends CanvasLayer

func _ready():
	ScoreManager.connect("ScoreUpdated", update_score_label)
	
func update_score_label():
	$Label.text = "SCORE: " + str(ScoreManager.score)
