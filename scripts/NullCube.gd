extends Pickup

var numbers = [
	load("res://sprites/numbers/null/null numbers1.png"),
	load("res://sprites/numbers/null/null numbers2.png"),
	load("res://sprites/numbers/null/null numbers3.png"),
	load("res://sprites/numbers/null/null numbers4.png"),
	load("res://sprites/numbers/null/null numbers5.png"),
	load("res://sprites/numbers/null/null numbers6.png"),
]

export var color_curve: Curve


func _ready():
	variant_max = len(numbers) - 1
	._ready()
	
	var new_mat: SpatialMaterial = SpatialMaterial.new()
	new_mat.albedo_color = Color(0,0,0,1)
	var step: float = float(task.variant)/float(variant_max + 1)
	new_mat.albedo_color.r = color_curve.interpolate(fmod(step, 1))
	new_mat.albedo_color.g = color_curve.interpolate(fmod(step+0.75, 1))
	new_mat.albedo_color.b = color_curve.interpolate(fmod(step+0.5, 1))
	new_mat.uv1_scale.x = 3
	new_mat.uv1_scale.y = 2
	new_mat.albedo_texture = numbers[task.variant]
	new_mat.flags_transparent = true
	new_mat.flags_unshaded = true 
	$Numbers.set_surface_material(0, new_mat)
	$Numbers.visible = true
	
func use_on(obj):
	if obj is NullPlate:
		if obj.task.variant == task.variant:
			obj.place_cube_on(self)
			return Result.CONSUMED
		else:
			UI.log("This NullPlate has the wrong number.")
			return Result.WRONG_VARIANT
	return Result.FAIL

func lock():
	type = Type.NONE
	$AnimationPlayer.play("flash")
