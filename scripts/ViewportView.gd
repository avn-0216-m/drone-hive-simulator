extends TextureRect

func _process(delta):
	texture = get_node("../../SubViewport").get_texture()
