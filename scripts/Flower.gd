extends Pickup
class_name Flower

func on_pickup():
	emit_signal("task_completed", task_id)
	.on_pickup()
	if interactable_name == "a 52lip":
		UI.dialog.queue("Congratulations! You've found a 52lip. They are a very special and beautiful little flower.")
		UI.dialog.queue("Make sure you treat it with extra care and attention.")
		UI.dialog.queue("It will get quite fussy if you forget to water it.")
