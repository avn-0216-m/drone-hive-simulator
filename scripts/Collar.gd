extends Pickup

func own(object):
	print("you now have a cute puppy!")
	object.pet.visible = true
	object.collar.visible = true
	object.lena.visible = false
	object.interactable = false
	return true

func _ready():
	icon_scale = Vector3(1.5,1.5,0)
	icon_translation = Vector3(0,0,0.01)

func get_class() -> String:
	return "Collar"
