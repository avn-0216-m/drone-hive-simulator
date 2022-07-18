extends Pickup

func use_on(obj):
	if obj is NullPlate:
		obj.place_cube_on(self)
		return Result.CONSUMED
