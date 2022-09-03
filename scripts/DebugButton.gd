extends Button

signal respawn
signal instance_level
signal add_tasks
signal generate_floor
signal generate_walls
signal random_music
signal reset_level

func _ready():
	connect("pressed",self,"on_click")
	
func on_click():
	match(name):
		"Respawn drone":
			emit_signal("respawn")
		"Reset level":
			emit_signal("reset_level")
		"Generate floor":
			emit_signal("generate_floor")
		"Add tasks":
			emit_signal("add_tasks")
		"Instance level":
			emit_signal("instance_level")
		"Hide debug menu":
			get_parent().get_parent().visible = false
		"Random music":
			emit_signal("random_music")
		"Test dialog":
			UI.dialog.queue("beep beep beep boooop... beep!")
		"Recharge drone":
			continue
		"Generate walls":
			emit_signal("generate_walls")
		_:
			print("Debug command not recognized/implemented.")
