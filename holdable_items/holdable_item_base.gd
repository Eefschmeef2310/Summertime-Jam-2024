extends Resource
class_name HoldableItem

enum item_type {
	Kebab,
	Sausage,
	Chicken
}

@export var type : item_type
@export var uncooked_texture : Texture
@export var cooked_texture : Texture
