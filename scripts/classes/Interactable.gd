extends CharacterBody3D
class_name Interactable

signal task_complete(task)

var task: Task = Task.new()
@export var task_name: String = "null"
@export var sprinkler_source: PackedScene
@export var sprinkler_min: int = 1
@export var sprinkler_max: int = 5
@export var sprinkler_radius: float = 10.0

func _ready():
	if task_name == "null":
		task = null
	else:
		task.task_name = task_name
		task.task_object = self
		
	# Clamp the max so nothing fucky happens by accident
	sprinkler_max = max(sprinkler_min, sprinkler_max)
		
	if sprinkler_source != null:
		for i in randi_range(sprinkler_min, sprinkler_max):
			var sprinkler_obj = sprinkler_source.instantiate()
			sprinkler_obj.position = position
			sprinkler_obj.position.x += randf_range(sprinkler_radius * -1, sprinkler_radius)
			sprinkler_obj.position.z += randf_range(sprinkler_radius * -1, sprinkler_radius)
			get_parent().add_child(sprinkler_obj)
			

func interact(item: Node, interactor: Node):
	return

func pickup(_item: Node, interactor: Node):
	# This is a helper script that all interactables have, but that only pickups should call.
	# It'll do something like...
	# interactor.inventory.add_item(self)
	# Which will then handle the despawning of the item, etc.
	return
	
func _physics_process(_delta: float) -> void:	
	if not is_on_floor():
		velocity.y += -0.1
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)
