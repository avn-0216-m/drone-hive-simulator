extends Pickup
class_name Flower

func gift(object):
	print("you have given a lovely flower to a friend :)")
	object.heart.visible = true
	object.lena.visible = false
	object.interactable = false
	return true

func _ready():
	icon_scale = Vector3(1.5,1.5,0)
	icon_translation = Vector3(0,0,0.01)

func get_class() -> String:
	return "Flower"
