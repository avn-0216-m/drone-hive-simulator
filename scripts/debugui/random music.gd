extends Button

# Debug UI

func _ready():
	connect("pressed",self,"pressed")

func pressed():
	get_tree().get_root().get_node("Main/Viewport/Game/Music").change_music()
