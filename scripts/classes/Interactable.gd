extends KinematicGravity
class_name Interactable

var interactable: bool = true # If the object can be interacted with.
var cursor_offset = Vector3(0,1,0) # Where the cursor should reside relative to the object.
enum Type {NONE, ITEMS, DIRECT, BOTH}
var type = Type.BOTH

func interact(interactor):
	print(self.name + " was interacted with. This is the default interaction function.")
