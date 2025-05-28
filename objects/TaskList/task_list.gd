extends Control

var tasks: Array = []

@onready var list_item_src = preload("res://objects/TaskList/TaskListItem.tscn")

func _process(delta):
	if Input.is_action_just_pressed("task_list"):
		print("whee")
		$AnimationPlayer.play("Up")
		$RapidDelete.stop()
	elif Input.is_action_just_released("task_list"):
		$AnimationPlayer.play_backwards("Up")
		$RapidDelete.start(0.1)
		tasks = []

func show_tasks(found_tasks: Array):
	print("showin tasks")
	tasks = found_tasks
	$PopTimer.start()

func pop_task():
	var task_obj = tasks.pop_back()
	if task_obj == null: return
	var list_item = list_item_src.instantiate()
	list_item.text = task_obj.task_name
	if task_obj.task.task_complete:
		list_item.text = "[s]" + list_item.text + "[/s]"
	$Control/TextureRect/VBoxContainer.add_child(list_item)
	
func delete_line():
	var line = $Control/TextureRect/VBoxContainer.get_child(0)
	if line == null:
		$RapidDelete.stop()
	else:
		$Control/TextureRect/VBoxContainer.get_child(0).queue_free()
