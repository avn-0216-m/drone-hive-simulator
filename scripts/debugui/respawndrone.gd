extends Button

# Debug UI

func _ready():
	connect("pressed",self,"pressed")

func pressed():
	print("respawning drone")
	var drone = get_tree().get_root().get_node("Main/Viewport/Game/Drone")
	var level = get_tree().get_root().get_node("Main/Viewport/Game/Level")
	
	drone.translation = level.respawn_point
