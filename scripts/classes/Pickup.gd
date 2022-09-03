extends Interactable
class_name Pickup

# Record parent so object can be readded in the right place in the scene tree when dropped.
onready var parent: Node = get_parent()

# Static image to use in inventory slot.
export var icon: Texture

export var icon_size: float = 0.01

# Determines if an object is deleted on pickup.
export var infinite: bool = false 

signal picked_up
signal dropped

export var pickup_text = "Picked up"
export var drop_text = "Dropped"

enum Result {
	FAIL, # The item is not compatible with what you're using it on.
	WRONG_VARIANT,
	SUCCESS, # The item is used, but not consumed.
	CONSUMED # The item is used and removed from the inventory.
	}

# Item that is stored in inventory.
var source: Node = null

func _ready():
	._ready()
	connect("dropped", self, "on_drop")
	connect("picked_up", self, "on_pickup")

func interact(interactor):
	if infinite:
		emit_signal("picked_up")
		return source
	else:
		parent.remove_child(self)
		emit_signal("picked_up")
		return self

	
func on_drop():
	UI.log(drop_text + " " + interactable_name + ".")

func on_pickup():
	if infinite:
		UI.log(pickup_text + " " + source.interactable_name + ".")
	else:
		UI.log(pickup_text + " " + interactable_name + ".")
		
func use_on(target):
	# Extend out custom behaviour for using on items.
	return Result.FAIL
