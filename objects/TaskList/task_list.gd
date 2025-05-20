extends Control

func _process(delta):
	if Input.is_action_pressed("task_list"):
		visible = true
	else:
		visible = false
