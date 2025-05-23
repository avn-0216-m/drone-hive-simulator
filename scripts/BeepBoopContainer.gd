extends Node3D

var height_tw

var gone = false

func _ready():
	height_tw = Tween.new()
	add_child(height_tw)
	height_tw.connect("tween_completed", Callable(self, "done"))
	height_tw.interpolate_property(self, "position:y", 4.4, 5, 1, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	height_tw.start()

	
func done(obj, key):
	if gone:
		queue_free()
	else:
		gone = true
		height_tw.interpolate_property(self, "position:y", 5, 10, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
		height_tw.start()
