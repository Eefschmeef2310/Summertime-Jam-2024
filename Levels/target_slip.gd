extends PanelContainer

var data: CustomerData
var separation = 135.0

var tween: Tween

func _ready():
	modulate.a = 0
	position = Vector2(get_index() * separation, 200)
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1, 1)
	tween.parallel().tween_property(self, "position:y", 0, 1)


func _process(delta):
	position.x = lerp(position.x, get_index() * separation, 5 * delta)


func set_data(d: CustomerData):
	data = d
	
	var s: String = ""
	s += "- " + data.headpiece.text
	s += "\n- " + data.clothing.text
	s += "\n- " + data.habit.description
	s += "\n- Likes " + data.order_pref.name.to_lower()
	$Margin/VBox/Details.text = s

func complete_slip():
	$CompleteTexture.show()
	if tween:
		tween.kill()
	tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0, 1)
	tween.parallel().tween_property(self, "position:y", 200, 1)
	tween.tween_callback(queue_free)
