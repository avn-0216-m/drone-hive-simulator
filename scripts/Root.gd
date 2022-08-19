extends Control

func _ready():
	get_node("DebugUI/Level/Respawn").connect("respawn",get_node("Viewport/Game"),"respawn_drone")
