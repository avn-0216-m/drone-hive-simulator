extends HBoxContainer

@onready var arrow: TextureRect = get_node("Control/TextureRect")
@onready var label: RichTextLabel = get_node("TaskListItem")
var arrow_rot: float = 0.0
var complete: bool = false

func _ready():
	label.visible_ratio = 0.0
	arrow.visible = false
	arrow.modulate.a = 0.0
	arrow.rotation_degrees = 180 # if you want the arrow to SPEEEEN then change this to a higher value
	label.clear()

func set_text(text: String):
	if complete:
		label.push_strikethrough()
		label.push_color(Color.DARK_GRAY)
	label.append_text(text)
	if complete:
		label.push_strikethrough()
		label.push_color(Color.DARK_GRAY)
	var tween = create_tween()
	tween.tween_property(label, "visible_ratio", 1.0, 0.5)
	tween.finished.connect(show_arrow)
	
func show_arrow():
	if label.text == "Nothing here..." or complete: return # hey, if it works.
	arrow.visible = true
	var tween = create_tween().set_parallel(true).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(arrow, "rotation_degrees", arrow_rot, 0.3)
	tween.tween_property(arrow, "modulate:a", 1.0, 0.2)
