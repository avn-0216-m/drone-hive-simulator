extends "res://scripts/classes/KinematicGravity.gd"
class_name Interactable

var cursor_offset = Vector3(0,1.5,0) # Where the cursor should reside relative to the object.
var task: TaskManager.Task = TaskManager.Task.new() # Corresponds to a relevant task if applicable.
var variant: int = 0
onready var nearby_area = get_node("Nearby")
export var variant_max = 10
enum Type {
	NONE, # Not interactable 
	ITEMS, # Only interactable by using an item on it
	DIRECT, # Only interactable directly
	BOTH} # Interactable directly and with items.
var type = Type.BOTH

export var interactable_name = "UNNAMED INTERACTABLE PLEASE CHANGE"

signal task_completed(task)

func _ready():
	connect("task_completed",TaskManager,"on_task_completion")
	task.variant = set_variant_within_range(variant_max)
	if nearby_area:
		nearby_area.connect("body_entered",self,"body_nearby")
		nearby_area.connect("body_exited",self,"body_left")

func body_nearby(body):
	print(name + ": default body nearby func.")
	
func body_left(body):
	print(name + ": default body left func.")

func set_variant_within_range(maximum: int) -> int:
	if task.variant <= maximum:
		return task.variant
	return int(lerp(0, maximum, float(task.variant) / 10.0))

func interact(interactor):
	print(name + ": default interaction func.")
