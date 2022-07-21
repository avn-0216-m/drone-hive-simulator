extends Interactable
class_name NullPlate

onready var sprite = get_node("Pressure/AnimatedSprite3D")

func _ready():
	._ready()
	type = Type.ITEMS

func place_cube_on(cube):
	add_child(cube)
	type = Type.NONE
	cube.translation = Vector3(0,5,0)
	$AnimationPlayer.play("activate")
	cube.lock()


func complete_task():
	emit_signal("task_completed", task_id)
	
