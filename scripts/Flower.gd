extends Pickup
class_name Flower

func gift():
	print("gifting flower :)")

func _ready():
	print("Flower is ready")
	icon_scale = Vector3(1.5,1.5,0)
	icon_translation = Vector3(0,0,0.01)
	interactions = {Friend: gift()}
	
