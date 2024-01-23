extends Sprite2D
class_name HoldableItemScene

var item_resource : HoldableItem = HoldableItem.new()
var item_type

var cooked: bool = false
var poisoned: bool = false

#Use set parent and change position

func _ready():
	texture = item_resource.cooked_texture if cooked else item_resource.uncooked_texture
	item_type = item_resource.type

func _process(_delta):
	if !$CookTimer.is_stopped():
		$TextureProgressBar.value = ($CookTimer.time_left / $CookTimer.wait_time)
	
func start_cook_timer():
	$CookTimer.start()

func _on_cook_timer_timeout():
	cooked = true;
	texture = item_resource.cooked_texture
