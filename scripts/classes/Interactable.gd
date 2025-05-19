extends CharacterBody3D
class_name Interactable
	
func interact(item: Node, interactor: Node):
	return
	
func _ready():
	# TODO: Don't bother with this floor snap business. Just raycast instead. Or at least raycast first.
	velocity = Vector3(0,0.01,0)
	move_and_slide()
	apply_floor_snap()
