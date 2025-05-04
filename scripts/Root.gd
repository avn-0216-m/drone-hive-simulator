extends Control

func _process(delta):
	# Sync cameras from both viewports
	#get_node("Composite/BackgroundTexture/SubViewport/BackgroundCylinder/Camera3D").rotation_degrees = get_node("Composite/GameTexture/SubViewport/Game/Camera3D").rotation_degrees
	return
#func _ready():
	#get_node("DebugUI/Level/Respawn drone").connect(
		#"respawn",
		#get_node("Composite/GameTexture/SubViewport/Game"),
		#"respawn_drone"
		#)
	#get_node("DebugUI/Level/Add tasks").connect(
		#"add_tasks",
		#get_node("Composite/GameTexture/SubViewport/Game/Level"),
		#"a_add_tasks_to_gridmap"
		#)
	#get_node("DebugUI/Level/Instance level").connect(
		#"instance_level",
		#get_node("Composite/GameTexture/SubViewport/Game/Level"),
		#"a_instance_gridmap"
		#)
	#get_node("DebugUI/Level/Generate walls").connect(
		#"generate_walls",
		#get_node("Composite/GameTexture/SubViewport/Game/Level"),
		#"a_add_walls_to_gridmap"
	#)
	#get_node("DebugUI/Other/Random music").connect(
		#"random_music",
		#get_node("Composite/GameTexture/SubViewport/Game/Music"),
		#"change_music"
		#)
	#get_node("DebugUI/Level/Reset level").connect(
		#"reset_level",
		#get_node("Composite/GameTexture/SubViewport/Game/Level"),
		#"a_reset_level"
	#)
	#get_node("DebugUI/Level/Generate floor").connect(
		#"generate_floor",
		#get_node("Composite/GameTexture/SubViewport/Game/Level"),
		#"a_add_floor_to_gridmap"
	#)
