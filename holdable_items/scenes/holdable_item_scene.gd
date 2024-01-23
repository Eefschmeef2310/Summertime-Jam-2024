extends Sprite2D
class_name HoldableItemScene

var item_resource : OrderResource = OrderResource.new()

var cooked: bool = false
var poisoned: bool = false

#Use set parent and change position

func _ready():
	texture = item_resource.cooked_texture if cooked else item_resource.uncooked_texture

func _process(_delta):
	if !$CookTimer.is_stopped():
		$TextureProgressBar.value = ($CookTimer.time_left / $CookTimer.wait_time)
	
func start_cook_timer():
	$CookTimer.start()

func _on_cook_timer_timeout():
	cooked = true;
	texture = item_resource.cooked_texture
