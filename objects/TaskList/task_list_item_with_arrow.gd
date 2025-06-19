extends HBoxContainer

@onready var arrow: TextureRect = get_node("Control/TextureRect")
@onready var label: RichTextLabel = get_node("TaskListItem")
var arrow_rot: float = 0.0

func _ready():
	label.visible_ratio = 0.0
	arrow.visible = false
	arrow.modulate.a = 0.0
	label.clear()

func set_text(text: String, complete: bool):
	if complete:
		label.push_strikethrough()
	label.append_text(text)
	if complete:
		label.push_strikethrough()
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, 0.5)
	tween.finished.connect(show_arrow)
	
func show_arrow():
	arrow.visible = true
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(arrow, "rotation_degrees", arrow_rot, 0.3)
	tween.tween_property(arrow, "modulate:a", 1.0, 0.2)
