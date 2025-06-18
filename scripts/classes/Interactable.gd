extends CharacterBody3D
class_name Interactable

signal task_complete(task)

var task: Task = Task.new()
@export var task_name: String = "null"
@export var sprinkler_source: PackedScene
@export var sprinkler_min: int = 1
@export var sprinkler_max: int = 5
@export var sprinkler_radius: float = 10.0
@export var pickup: bool = false
@export var pickup_scale: float = 0.0
@export var cursor_offset: float = 3

var test_width: int = 1
var test_length: int = 5

func _ready():
	if task_name == "null":
		task = null
	else:
		task.task_name = task_name
		task.task_object = self
		
	# Clamp the max so nothing fucky happens by accident
	# Even though I'm reasonably sure Godot supports back-to-front range iteration.
	sprinkler_max = max(sprinkler_min, sprinkler_max)

func sprinkle_objects(drop_points: Array):
	# TODO: link the parent interactable to its original room so that the
	# drop points placeholder can be removed to avoid re-use.
	if len(drop_points) == 0 or sprinkler_source == null: return
	print(len(drop_points))
	for i in randi_range(sprinkler_min, sprinkler_max):
		var sprinkler_obj = sprinkler_source.instantiate()
		var drop_point = drop_points.pick_random()
		sprinkler_obj.position = drop_point + Vector3(0,10,0)
		drop_points.erase(drop_point)
		get_parent().add_child(sprinkler_obj)

func interact(item: Node, interactor: Node):
	if pickup and item == null:
		interactor.inventory.pick_up_item(self)
	
func _physics_process(_delta: float) -> void:	
	if not is_on_floor():
		velocity.y += -1
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)
