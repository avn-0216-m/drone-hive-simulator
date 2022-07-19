extends Pickup

export var number1: StreamTexture
export var number2: StreamTexture
export var number3: StreamTexture
export var number4: StreamTexture
export var number5: StreamTexture
export var number6: StreamTexture

var variants = [
	number1,
	number2,
	number3,
	number4,
	number5,
	number6
]

func _ready():
	._ready()
	$Numbers.get_surface_material(0).set("albedo_texture", number1)
	
func use_on(obj):
	if obj is NullPlate:
		if obj.variant == variant:
			obj.place_cube_on(self)
			return Result.CONSUMED
		else:
			UI.log("This is not the right plate for this cube.")
			return Result.WRONG_VARIANT
	return Result.FAIL

func lock():
	type = Type.NONE
	$AnimationPlayer.play("flash")
