extends Node

# 'Cus my node structure is kinda fucky, instead of having the UI itself be an
# singleton, I need to have a controller singleton that interfaces with a
# concrete UI node instead.

onready var activitylog: Node = get_tree().get_root().get_node("Main/ActivityLog")

func log(text: String):
	var label = Label.new()
	label.text = text
	activitylog.add_child(label)
