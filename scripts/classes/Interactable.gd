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

var sprinkler_tests: Array = [
	Vector3(-1,-10,1),
	Vector3(0,-10,1),
	Vector3(1,-10,1),
	Vector3(-1,-10,0),
	Vector3(0,-10,0),
	Vector3(1,-10,0),
	Vector3(-1,-10,-1),
	Vector3(0,-10,-1),
	Vector3(1,-10,-1),
]

func _ready():
	if task_name == "null":
		task = null
	else:
		task.task_name = task_name
		task.task_object = self
		
	# Clamp the max so nothing fucky happens by accident
	# Even though I'm reasonably sure Godot supports back-to-front range iteration.
	sprinkler_max = max(sprinkler_min, sprinkler_max)
		
	if sprinkler_source != null:
		for i in randi_range(sprinkler_min, sprinkler_max):
			var sprinkler_obj = sprinkler_source.instantiate()
			sprinkler_obj.position = position
			sprinkler_obj.position.x += randf_range(-sprinkler_radius, sprinkler_radius)
			sprinkler_obj.position.z += randf_range(-sprinkler_radius, sprinkler_radius)
			get_parent().add_child(sprinkler_obj)

func values_match(values, expected_value):
	return values.all(func(value): return value == expected_value)

func interact(item: Node, interactor: Node):
	if pickup and item == null:
		interactor.inventory.pick_up_item(self)
	
func _physics_process(_delta: float) -> void:	
	if not is_on_floor():
		velocity.y += -1
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)
