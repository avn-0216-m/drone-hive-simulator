extends Button

signal respawn

export(
	String,
	"Select option",
	"Respawn drone",
	"Reset level",
	"Generate floor",
	"Add tasks",
	"Generate walls",
	"Instance level",
	"Hide debug menu",
	"Random music",
	"Test dialog",
	"Recharge drone"
	) var function

func _ready():
	connect("pressed",self,"on_click")
	
func on_click():
	match(function):
		"Respawn drone":
			print("Respawning drone.")
			emit_signal("respawn")
		"Reset level":
			continue
		"Generate floor":
			continue
		"Add tasks":
			continue
		"Instance level":
			continue
		"Hide debug menu":
			get_parent().get_parent().visible = false
		"Random music":
			continue
		"Test dialog":
			UI.dialog.queue("beep beep beep boooop... beep!")
		"Recharge drone":
			continue
		_:
			print("Debug command not recognized.")
