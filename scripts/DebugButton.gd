extends Button

signal respawn
signal instance_level
signal add_tasks
signal generate_floor

func _ready():
	connect("pressed",self,"on_click")
	
func on_click():
	match(name):
		"Respawn drone":
			emit_signal("respawn")
		"Reset level":
			continue
		"Generate floor":
			continue
		"Add tasks":
			emit_signal("add_tasks")
		"Instance level":
			emit_signal("instance_level")
		"Hide debug menu":
			get_parent().get_parent().visible = false
		"Random music":
			continue
		"Test dialog":
			UI.dialog.queue("beep beep beep boooop... beep!")
		"Recharge drone":
			continue
		_:
			print("Debug command not recognized/implemented.")
