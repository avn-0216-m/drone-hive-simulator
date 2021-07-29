extends ColorRect

var wipe_direction: String = "IN"

func _ready():
	print(material.get_shader_param("screen_size"))
	material.set_shader_param("screen_size", rect_size)
	print(material.get_shader_param("screen_size"))
	
func _process(delta):
	if wipe_direction == "IN":
		material.set_shader_param("cutoff", lerp(material.get_shader_param("cutoff"), -0.15, 0.02))
	else:
		material.set_shader_param("cutoff", lerp(material.get_shader_param("cutoff"), 1.15, 0.02))
		if material.get_shader_param("cutoff") < 0.95:
			material.set_shader_param("cutoff", 1)

func wipe_in():
	wipe_direction = "IN"
	material.set_shader_param("cutoff", 1)
	
func wipe_out():
	wipe_direction = "OUT"
	material.set_shader_param("cutoff", 0)
