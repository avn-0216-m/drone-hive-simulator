extends Interactable
class_name NullPlate

onready var sprite = get_node("Pressure/AnimatedSprite3D")

var numbers = [
	load("res://sprites/numbers/null/null numbers1.png"),
	load("res://sprites/numbers/null/null numbers2.png"),
	load("res://sprites/numbers/null/null numbers3.png"),
	load("res://sprites/numbers/null/null numbers4.png"),
	load("res://sprites/numbers/null/null numbers5.png"),
	load("res://sprites/numbers/null/null numbers6.png"),
]

func _ready():
	variant_max = len(numbers) - 1
	._ready()
	type = Type.ITEMS
	$Pressure/Texture/Number.frame = variant

func place_cube_on(cube):
	add_child(cube)
	type = Type.NONE
	cube.translation = Vector3(0,5,0)
	$AnimationPlayer.play("activate")
	cube.lock()


func complete_task():
	emit_signal("task_completed", task_id)
	
