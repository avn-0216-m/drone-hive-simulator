extends Pickup

func get_class() -> String:
	return "WeightedCube"
	
func place_on_button(button):
	translation = button.translation + Vector3(0,5,0)
	button.get_parent().add_child(self)
	print("Putting down")
	return true
	
func _ready():
	interactions = {"WeightedButton": funcref(self, "place_on_button")}
