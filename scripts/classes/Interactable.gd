extends "res://scripts/classes/KinematicGravity.gd"
class_name Interactable

var interactable: bool = true # If the object can be interacted with.
var cursor_offset = Vector3(0,1.5,0) # Where the cursor should reside relative to the object.
enum Type {
	NONE, # Not interactable 
	ITEMS, # Only interactable by using an item on it
	DIRECT, # Only interactable directly
	BOTH} # Interactable directly and with items.
var interact_type = Type.BOTH
# TODO: implement this ^

func interact(interactor):
	print(self.name + " was interacted with. This is the default interaction function.")
