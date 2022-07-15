extends Interactable
class_name Pickup

# Record parent so object can be readded in the right place in the scene tree when dropped.
onready var parent: Node = get_parent()

# Static image to use in inventory slot.
export var icon: Texture

# Determines if an object is deleted on pickup.
var infinite: bool = false 

var picked_up: bool = false

export var pickup_text = "picked up."
export var drop_text = "dropped."

# Item that is stored in inventory.
var source: Node = null

func _ready():
	connect("tree_entered", self, "on_drop")

func interact(interactor):
	if !infinite:
		parent.remove_child(self)
		UI.log(interactable_name + pickup_text)
		picked_up = true
		return self
	else:
		return source
	
func on_drop():
	UI.log(interactable_name + " " + drop_text)
	
func use_on(target):
	# Extend out custom behaviour for using on items.
	return
