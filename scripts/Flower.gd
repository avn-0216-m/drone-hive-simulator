extends Pickup
class_name Flower

func on_pickup():
	emit_signal("task_completed", task_id)
	.on_pickup()

