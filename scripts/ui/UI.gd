extends Control

onready var activity_log = get_node("Anchor/ActivityLog")
onready var label_src = load("res://objects/ui/TemporaryLabel.tscn")

onready var task_list = get_node("Anchor/TaskList")

export var tick: Texture
export var cross: Texture
export var treasure: Texture

const LOG_MAX_HEIGHT = 400
const LOG_SIZE_PER_LABEL = 300

func log(text: String):
	var label = label_src.instance()
	label.text = text
	activity_log.add_child(label)

func add_task(task):
	return

func set_tasks(tasks: Array):
	for task in tasks:
			task_list.add_item(task.title, tick if task.complete else cross)

func update_task(id, icon):
	task_list.set_item_icon(id, icon)
