extends Interactable
class_name Pickup

var object # The object to spawn when placed down.
var icon # The texture to use as the inventory icon.
var interactions: Dictionary = {} # A string/func dict of other items this item can be used on.

# A pickup is an interactable object whose interact function
# will pick the item up and add it to the inventory.

func interact():
	# Dropping is handled seperately by the inventory, so interact should always pickup a pickup.
	print(self.name + "was picked up.")
