extends Pickup

export(Array, StreamTexture) var variants

func _ready():
	._ready()
	return
	$Numbers.get_surface_material(0).set("albedo_texture", variants[variant])
	$Numbers.visible = true
	
func use_on(obj):
	if obj is NullPlate:
		if obj.variant == variant:
			obj.place_cube_on(self)
			return Result.CONSUMED
		else:
			UI.log("This NullPlate has the wrong number.")
			return Result.WRONG_VARIANT
	return Result.FAIL

func lock():
	type = Type.NONE
	$AnimationPlayer.play("flash")
