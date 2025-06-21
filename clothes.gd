extends Interactable
class_name Clothes

@onready var clothes_sprites = [
	load("res://objects/tasks/washingmachine/jeanshorts.png"),
	load("res://objects/tasks/washingmachine/hoodie.png"),
	load("res://objects/tasks/washingmachine/tshirt.png"),
]

func _ready():
	super()
	$Sprite3D.texture = clothes_sprites.pick_random()
