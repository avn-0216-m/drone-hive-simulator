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
	get_node("DebugUI/Level/Generate walls").connect(
		"generate_walls",
		get_node("Viewport/Game/Level"),
		"a_add_walls_to_gridmap"
	)
	get_node("DebugUI/Other/Random music").connect(
		"random_music",
		get_node("Viewport/Game/Music"),
		"change_music"
		)
	get_node("DebugUI/Level/Reset level").connect(
		"reset_level",
		get_node("Viewport/Game/Level"),
		"a_reset_level"
	)
	get_node("DebugUI/Level/Generate floor").connect(
		"generate_floor",
		get_node("Viewport/Game/Level"),
		"a_add_floor_to_gridmap"
	)
