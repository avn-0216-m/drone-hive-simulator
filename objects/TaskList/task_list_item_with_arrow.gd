extends HBoxContainer

@onready var arrow = get_node("Control/TextureRect")
@onready var label = get_node("TaskListItem")

func set_text(text: String):
	label.text = text
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, 0.5)
