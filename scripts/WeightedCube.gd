extends Pickup
class_name WeightedCube

func get_class() -> String:
	return "WeightedCube"
	
func place_on_button(button):
	translation = button.translation + Vector3(0,5,0)
	skip_process = false
	velocity.y = 0
	button.get_parent().add_child(self)
	print("Putting down")
	return true

func use_on(target):
	if target is WeightedButton:
		print("Placing cube on button! Wow")
