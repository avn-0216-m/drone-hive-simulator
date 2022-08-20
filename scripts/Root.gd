extends Control

func _ready():
	get_node("DebugUI/Level/Respawn drone").connect(
		"respawn",
		get_node("Viewport/Game"),
		"respawn_drone"
		)
	get_node("DebugUI/Level/Add tasks").connect(
		"add_tasks",
		get_node("Viewport/Game/Level"),
		"a_add_tasks_to_gridmap"
		)
	get_node("DebugUI/Level/Instance level").connect(
		"instance_level",
		get_node("Viewport/Game/Level"),
		"a_instance_gridmap"
		)
