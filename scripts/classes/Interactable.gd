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

func _ready():
	if task_name == "null":
		task = null
	else:
		task.task_name = task_name
		task.task_object = self
		
	# Clamp the max so nothing fucky happens by accident
	# Even though I'm reasonably sure Godot supports back-to-front range iteration.
	sprinkler_max = max(sprinkler_min, sprinkler_max)

func sprinkle_objects(drop_points: Dictionary):
	if len(drop_points) == 0 or sprinkler_source == null: return
	for i in randi_range(sprinkler_min, sprinkler_max):
		var sprinkler_obj = sprinkler_source.instantiate()
		var drop_point = drop_points.keys().pick_random()
		sprinkler_obj.position = drop_point + Vector3(0,10,0)
		get_node(drop_points[drop_point]).erase_drop_point(drop_point)
		drop_points.erase(drop_point) # and erase it in this scope too
		get_parent().add_child(sprinkler_obj)

func interact(item: Node, interactor: Node):
	if pickup and item == null:
		interactor.inventory.pick_up_item(self)
		interactor.focus = null
	
func complete_task():
	if task.task_complete:
		return
	task_complete.emit(task)
	task.task_complete = true
	
func _physics_process(_delta: float) -> void:	
	if not is_on_floor():
		velocity.y += -1
		move_and_slide()
	else:
		velocity = Vector3(0,0,0)
