extends Node

signal level_complete

var tiles: Array = []

onready var music_player = get_node("Music")
onready var grid_map = get_node("GridMap")
onready var background = get_tree().get_root().get_child(0).get_node("Background")

func _ready():
	print("Assigning camera.")
	get_node("Camera").follow_target = get_node("Drone")
	
	print("Root game node ready!")
	music_player.change_music()
	music_player.change_music()
	print("Starting intro wipe")
	background.wipe_in()
	
func _process(delta):
	if Input.is_action_just_pressed("debug_bg_in"):
		background.wipe_in()
	elif Input.is_action_just_pressed("debug_bg_out"):
		background.wipe_out()
	elif Input.is_action_just_pressed("debug_mus_cycle"):
		music_player.change_music()

func setup_level(difficulty: int):
	# This function tears down and sets up a level each time it is called.
		# Spawn floor tiles.
		# Remove a random floor tiles.
		# Adds tasks to complete.
		# Add wall tiles.
	print("Beginning level setup.")

