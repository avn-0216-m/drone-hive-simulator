extends Interactable
class_name Pickup

# Record parent so object can be readded in the right place in the scene tree when dropped.
onready var parent: Node = get_parent()

# Static image to use in inventory slot.
export var icon: Texture

# Determines if an object is deleted on pickup.
var infinite: bool = false 

signal picked_up

export var pickup_text = "Picked up"
export var drop_text = "Dropped"

# Item that is stored in inventory.
var source: Node = null

func _ready():
	connect("tree_entered", self, "on_drop")
	connect("picked_up", self, "on_pickup")

func interact(interactor):
	if !infinite:
		parent.remove_child(self)
		emit_signal("picked_up")
		return self
	else:
		return source
	
func on_drop():
	UI.log(drop_text + " " + interactable_name + ".")

func on_pickup():
	UI.log(pickup_text + " " + interactable_name + ".")
	
func use_on(target):
	# Extend out custom behaviour for using on items.
	return false
