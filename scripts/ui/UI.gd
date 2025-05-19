extends Control

@onready var activity_log = get_node("Anchor/ActivityLog")
@onready var label_src = load("res://objects/UI/TemporaryLabel.tscn")

@onready var task_list = get_node("Anchor/TaskList")

@export var tick: Texture2D
@export var cross: Texture2D
@export var treasure: Texture2D

@onready var dialog = get_node("Anchor/Dialog")
@onready var battery = get_node("Anchor/Battery")

func log(text: String):
	var label = label_src.instantiate()
	label.text = text
	activity_log.add_child(label)

func add_task(task):
	return

func set_tasks(tasks: Array):
	for task in tasks:
			task_list.add_item(task.title, tick if task.complete else cross)

func update_task(id, icon):
	task_list.set_item_icon(id, icon)
