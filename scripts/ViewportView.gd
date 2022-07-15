extends TextureRect

func _process(delta):
	texture = get_node("../../Viewport").get_texture()
