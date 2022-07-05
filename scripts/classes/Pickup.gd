extends Interactable
class_name Pickup

# Record parent so object can be readded in the right place in the scene tree when dropped.
onready var parent: Node = get_parent() 

# Static image to use in inventory slot.
export var inventory_icon: ImageTexture

# Determines if an object is deleted on pickup.
var infinite: bool = false 

# Item that is stored in inventory.
var source: PackedScene 

func pack_source():
	source = PackedScene.new()
	source.pack(self)

func interact(interactor):
	if !infinite:
		queue_free()
	# Pack source at the moment of pickup so that object state changes are always preserved.
	pack_source()
	return self
	
func on_drop():
	return
	
func use_on(target):
	# Extend out custom behaviour for using on items.
	return
