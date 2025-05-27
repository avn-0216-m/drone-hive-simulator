extends CharacterBody3D
class_name Interactable

var task: Task = Task.new()
@export var task_name: String = "DEFAULTSTRING!!"

func _ready():
	if task_name == "null":
		task = null
	else:
		task.task_name = task_name
		task.task_object = self

func interact(item: Node, interactor: Node):
	return
	
func _physics_process(_delta: float) -> void:	
	if not is_on_floor():
		velocity.y += -0.1
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)
