extends "res://scripts/classes/KinematicGravity.gd"
class_name Interactable

var interactable: bool = true # If the object can be interacted with.
var cursor_offset = Vector3(0,1.5,0) # Where the cursor should reside relative to the object.
var task_id: int = -1 # Corresponds to a relevant task if applicable.
enum Type {
	NONE, # Not interactable 
	ITEMS, # Only interactable by using an item on it
	DIRECT, # Only interactable directly
	BOTH} # Interactable directly and with items.
var type = Type.BOTH
# TODO: implement this ^

signal task_completed(task_id)

func _ready():
	connect("task_completed",TaskManager,"on_task_completion")

export var interactable_name = "UNNAMED INTERACTABLE PLEASE CHANGE"

func interact(interactor):
	print(interactable_name + " (" + name + ") was interacted with. This is the default interaction function.")
