extends Control

func _ready():
	get_node("Debug/Level/Respawn").connect("respawn",get_node("Viewport/Game"),"respawn_drone")
