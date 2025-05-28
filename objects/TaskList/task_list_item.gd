extends RichTextLabel

func _ready():
	var tween = create_tween()
	tween.tween_property(self, "visible_ratio", 1.0, 0.5)
