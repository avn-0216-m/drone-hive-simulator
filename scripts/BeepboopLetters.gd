extends Sprite3D

export var delay: float = 1

func _ready():
	var opacity_tw = Tween.new()
	var height_tw = Tween.new()
	
	add_child(opacity_tw)
	add_child(height_tw)

	height_tw.interpolate_property(self, "translation:y", -1, 0, 1, Tween.TRANS_ELASTIC, Tween.EASE_OUT, delay)
	opacity_tw.interpolate_property(self, "opacity", 0, 1, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN, delay)

	height_tw.start()
	opacity_tw.start()
