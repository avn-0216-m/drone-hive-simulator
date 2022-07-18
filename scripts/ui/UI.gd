extends Control

onready var activitylog = get_node("Anchor/ActivityLog")
onready var label_src = load("res://objects/ui/TemporaryLabel.tscn")

const LOG_MAX_HEIGHT = 400
const LOG_SIZE_PER_LABEL = 300

func log(text: String):
	var label = label_src.instance()
	label.text = text
	activitylog.add_child(label)

func add_task(task):
	return
