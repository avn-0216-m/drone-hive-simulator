extends Control

var tasks: Array = []
var drone_pos: Vector3

@onready var list_item_src = preload("res://objects/TaskList/task_list_item_with_arrow.tscn")

func _process(delta):
	if Input.is_action_just_pressed("task_list"):
		print("whee")
		$AnimationPlayer.play("Up")
		for node in $Control/TextureRect/VBoxContainer.get_children():
			node.queue_free()
	elif Input.is_action_just_released("task_list"):
		$AnimationPlayer.play_backwards("Up")
		tasks = []

func show_tasks(found_tasks: Array, drone_pos: Vector3):
	print("showin tasks")
	tasks = found_tasks
	self.drone_pos = drone_pos
	self.drone_pos.y = 0
	$PopTimer.start(1)
	# Okay, so. Doing 3D node > 2D node > 3D node breaks inherited transformation
	# So position the "lookie" node manually when sending over the list of tasks.
	$Lookie.position = drone_pos

func pop_task():
	# First check to see if there are any nearby tasks, if not, print a fallback.
	if len(tasks) == 0 and $Control/TextureRect/VBoxContainer.get_child_count() == 0:
		var list_item = list_item_src.instantiate()
		print("nothing here fallback")
		$Control/TextureRect/VBoxContainer.add_child(list_item)
		list_item.arrow.visible = false
		list_item.set_text("Nothing here...")
		$PopTimer.stop()
		return
	
	# Then start popping tasks as normal.
	var task_obj = tasks.pop_back()
	if task_obj == null: return
	var list_item = list_item_src.instantiate()
	$Control/TextureRect/VBoxContainer.add_child(list_item)
	list_item.set_text(task_obj.task_name, task_obj.task.task_complete)
	var task_obj_norm: Vector3 = task_obj.global_position
	task_obj_norm.y = 0
	$Lookie.look_at(task_obj.global_position, Vector3.UP, true)
	# 3d objects rotate counter-clockwise while 2d objects rotate clockwise
	# so * -1 to flip and convert the rotation
	list_item.arrow_rot = snapped($Lookie.rotation_degrees.y * -1, 45)
