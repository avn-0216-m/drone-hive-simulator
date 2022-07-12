extends Pickup
class_name Flower

func gift(object):
	print("you have given a lovely flower to a friend :)")
	object.heart.visible = true
	object.lena.visible = false
	object.interactable = false
	return true

func get_class() -> String:
	return "Flower"
