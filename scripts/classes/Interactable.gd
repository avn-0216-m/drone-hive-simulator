extends KinematicGravity
class_name Interactable

var cursor_offset = Vector3(0,1,0) # Where the cursor should reside relative to the object.

func interact(interactor):
	print(self.name + " was interacted with.")
