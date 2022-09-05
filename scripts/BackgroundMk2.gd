extends TextureRect

func _process(delta):
	texture = get_node("../../BackgroundViewport").get_texture()
