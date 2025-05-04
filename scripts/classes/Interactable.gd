extends KinematicGravity
class_name Interactable

@export var cursor_offset: Vector3 = Vector3(0,1.5,0) # Where the cursor should reside relative to the object.
var task = Task.new() # Corresponds to a relevant task if applicable.
@onready var nearby_area = get_node("Nearby")
@export var variant_max = 10
enum Type {
	NONE, # Not interactable 
	ITEMS, # Only interactable by using an item on it
	DIRECT, # Only interactable directly
	BOTH} # Interactable directly and with items.
@export var type: Type = Type.BOTH

@export var interactable_name = "UNNAMED INTERACTABLE PLEASE CHANGE"

signal task_completed(task)

func _ready():
	#connect("task_completed",TaskManager,"on_task_completion")
	if task.variant == -1:
		randomize()
		task.variant = randi() % variant_max
	if nearby_area:
		nearby_area.connect("body_entered", Callable(self, "body_nearby"))
		nearby_area.connect("body_exited", Callable(self, "body_left"))

func body_nearby(body):
	print(name + ": default body nearby func.")
	
func body_left(body):
	print(name + ": default body left func.")

func set_variant_within_range(maximum: int) -> int:
	print("setting variant range")
	print(name)
	print(task.variant)
	if task.variant <= maximum:
		return task.variant
	return int(lerp(0, maximum, float(task.variant) / 10.0))

func interact(interactor):
	print(name + ": default interaction func.")
