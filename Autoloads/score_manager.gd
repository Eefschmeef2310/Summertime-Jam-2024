extends Node

signal ScoreUpdated()

var score : int:
	set(value):
		score = value
		ScoreUpdated.emit()

var playtime: float

func _process(delta):
	playtime += delta
