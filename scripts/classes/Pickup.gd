extends Interactable
class_name Pickup

var object # The object to spawn when placed down.
var icon # Static image to use in inventory slot.
# Icon can be automatically loaded if the pickup has a Sprite3D node.
var animation: String # Name of animation to use in inventory slot.
# Either an icon or an animation must be provided.
var icon_translation: Vector3 = Vector3(0,0,0.001) # How image should be positioned in inventory slot 
var icon_scale: Vector3 = Vector3(1,1,1) # How image should be scaled in inventory slot 
var interactions: Dictionary = {} # A class/func dict of other items this item can be used on.
var infinite: bool = false # Determines if an object is deleted on pickup.

# A pickup is an interactable object whose interact function
# will pick the item up and add it to the inventory.

func _ready():
	var sprite = get_node("Sprite3D")
	if sprite != null and sprite is Sprite3D:
		icon = sprite.texture

func interact(interactor):
	# Dropping is handled seperately by the inventory, so interact should always pickup a pickup.
	print(self.name + " was picked up.")
	if interactor.inventory.add_item(self) and !infinite:
		get_parent().remove_child(self)

func use_on(body):
	print("using on " + body.name + "!!!")
