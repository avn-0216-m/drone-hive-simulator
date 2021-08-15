extends ColorRect

var wipe_direction: String = "IN"

func _ready():
	print(material.get_shader_param("screen_size"))
	material.set_shader_param("screen_size", rect_size)
	print(material.get_shader_param("screen_size"))
	
func _process(delta):
	if wipe_direction == "IN":
#		material.set_shader_param("cutoff", lerp(material.get_shader_param("cutoff"), -0.15, 0.02))
		material.set_shader_param("cutoff", material.get_shader_param("cutoff") - 0.01)
		if material.get_shader_param("cutoff") < 0:
			wipe_direction = "NONE"
	elif wipe_direction == "OUT":
#		material.set_shader_param("cutoff", lerp(material.get_shader_param("cutoff"), 1.15, 0.02))
		material.set_shader_param("cutoff", material.get_shader_param("cutoff") + 0.02)
		if material.get_shader_param("cutoff") > 1:
			wipe_direction = "NONE"

func game_over_1():
	material.set_shader_param("cutoff", 1)
	wipe_direction = "NONE"

func wipe_in():
	wipe_direction = "IN"
	material.set_shader_param("slices", 5)
	material.set_shader_param("cutoff", 1)
	material.set_shader_param("slice_start_color", Color(0.8,0.5,0.8,1))
	material.set_shader_param("cutoff_bottom_diff_multiplier", 0.5)
	
func wipe_out():
	wipe_direction = "OUT"
	material.set_shader_param("slices", 10)
	material.set_shader_param("cutoff", 0)
	material.set_shader_param("slice_start_color", Color(0.5,0.3,0.5,1))
	material.set_shader_param("cutoff_bottom_diff_multiplier", 0.1)
