extends Control

var tasks: Array = []

@onready var list_item_src = preload("res://objects/TaskList/TaskListItem.tscn")

func _process(delta):
	if Input.is_action_just_pressed("task_list"):
		print("whee")
		$AnimationPlayer.play("Up")
		for node in $Control/TextureRect/VBoxContainer.get_children():
			node.queue_free()
	elif Input.is_action_just_released("task_list"):
		$AnimationPlayer.play_backwards("Up")
		tasks = []

func show_tasks(found_tasks: Array):
	print("showin tasks")
	tasks = found_tasks
	$PopTimer.start(1)

func pop_task():
	# First check to see if there are any nearby tasks, if not, print a fallback.
	if len(tasks) == 0 and $Control/TextureRect/VBoxContainer.get_child_count() == 0:
		var list_item = list_item_src.instantiate()
		print("nothing here fallback")
		print(tasks)
		list_item.text = "Nothing here..."
		$Control/TextureRect/VBoxContainer.add_child(list_item)
		$PopTimer.stop()
		return
	
	# Then start popping tasks as normal.
	var task_obj = tasks.pop_back()
	if task_obj == null: return
	var list_item = list_item_src.instantiate()
	list_item.text = task_obj.task_name
	if task_obj.task.task_complete:
		list_item.text = "[s]" + list_item.text + "[/s]"
	$Control/TextureRect/VBoxContainer.add_child(list_item)
