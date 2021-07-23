extends TextureRect

func _process(delta):
	texture = get_parent().get_node("Viewport").get_texture()
