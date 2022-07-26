extends Interactable
class_name NullPlate

onready var number = get_node("Pressure/Texture/Number")
export var color_curve: Curve

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
	
	var step: float = float(variant)/float(variant_max + 1)
	number.modulate.r = color_curve.interpolate(fmod(step, 1))
	number.modulate.g = color_curve.interpolate(fmod(step+0.75, 1))
	number.modulate.b = color_curve.interpolate(fmod(step+0.5, 1))

func place_cube_on(cube):
	add_child(cube)
	type = Type.NONE
	cube.translation = Vector3(0,5,0)
	$AnimationPlayer.play("activate")
	cube.lock()


func complete_task():
	emit_signal("task_completed", task.task_id)
	
