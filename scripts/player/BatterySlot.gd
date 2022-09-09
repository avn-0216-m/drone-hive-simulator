extends Sprite3D
class_name BatterySlot

func get_color():
	return material_override.albedo_color

func output():
	UI.log("Battery charged.")

func select(arg):
	return
