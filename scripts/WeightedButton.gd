extends Interactable

signal task_complete(node)
signal task_incomplete(node)

var button_pos = Vector3(0,0,0)

func get_class() -> String:
	return "WeightedButton"

func _physics_process(delta):
	$Button.translation = lerp($Button.translation, button_pos, 0.1)

func _ready():
	$Area.connect("body_entered",self,"body_entered")
	$Area.connect("body_exited",self,"body_exited")
	skip_process = true

func body_entered(body):
	if body.get_class() == "WeightedCube":
		emit_signal("task_complete", self)
		interactable = false
		button_pos = Vector3(0,-0.2,0)
	
func body_exited(body):
	if body.get_class() == "WeightedCube":
		print("cube exited")
		emit_signal("task_incomplete", self)
		interactable = true
		button_pos = Vector3(0,0,0)
