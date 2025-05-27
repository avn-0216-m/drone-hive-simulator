extends Control

var tasks: Array = []

@onready var list_item_src = preload("res://objects/TaskList/TaskListItem.tscn")

func _process(delta):
	if Input.is_action_just_pressed("task_list"):
		$AnimationPlayer.play("Up")
	elif Input.is_action_just_released("task_list"):
		$AnimationPlayer.play_backwards("Up")
		tasks = []

func show_tasks(found_tasks: Array):
	tasks = found_tasks
	$PopTimer.start()

func pop_task():
	var task = tasks.pop_back()
	if task == null: return
	var list_item = list_item_src.instantiate()
	list_item.text = task.task_name
	$Control/TextureRect/VBoxContainer.add_child(list_item)
