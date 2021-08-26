extends StaticBody

onready var entry_src = load("res://objects/Entry.tscn")

func _ready():
	$Area.connect("body_entered",self,"body_entered")
	
func body_entered(body):
	print("Body inside.")
	if body.name == "Drone":
		print("BEEPBEEPBEEP")
		
#		var entry = entry_src.instance()
#		entry.transform = transform
#		get_parent().add_child(entry)
#		entry.name = "EntryToNextFloor"
		get_tree().get_root().get_node("Main/Viewport/Game").difficulty = 30
		get_tree().get_root().get_node("Main/Viewport/Game").new_level()
		queue_free()
