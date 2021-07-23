extends ColorRect

func _ready():
	print(material.get_shader_param("screen_size"))
	material.set_shader_param("screen_size", rect_size)
