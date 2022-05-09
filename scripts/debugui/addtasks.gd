extends Button

func _ready():
	connect("pressed",self,"pressed")
	
func pressed():
	get_tree().get_root().get_node("Main/Viewport/Game/Level").a_add_tasks_to_gridmap()
