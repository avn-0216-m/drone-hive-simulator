extends Interactable
class_name WeightedButton

var button_pos = Vector3(0,0,0)

var weighed = false

func _physics_process(delta):
	$Button.translation = lerp($Button.translation, button_pos, 0.1)
	

func _ready():
	._ready()
	type = Type.ITEMS
	$Area.connect("body_entered",self,"body_entered")
	$Area.connect("body_exited",self,"body_exited")

func body_entered(body):
	if body.get_class() == "WeightedCube":
		emit_signal("task_complete", self)
		interactable = false
		button_pos = Vector3(0,-0.2,0)
	
func body_exited(body):
	if body.get_class() == "WeightedCube":
		interactable = true
		button_pos = Vector3(0,0,0)
