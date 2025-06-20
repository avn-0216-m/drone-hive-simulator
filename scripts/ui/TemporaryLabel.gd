extends Label

signal expired

func _ready():
	visible_ratio = 0
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, 0.5)
	tween.tween_property(self, "self_modulate:a", 0.0, 5)
	tween.finished.connect(destroy)

func destroy():
	expired.emit()
	queue_free()
