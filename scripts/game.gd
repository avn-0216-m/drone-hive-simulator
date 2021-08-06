extends Node

signal level_complete

var tiles: Array = []

onready var music = get_node("Music")
onready var grid_map = get_node("GridMap")
onready var background = get_tree().get_root().get_child(0).get_node("Background")
onready var camera = get_node("Camera")
onready var drone: KinematicBody = get_node("Drone")

func _ready():
	print("Assigning camera.")
	camera.follow_target = drone
	
	drone.connect("shutdown_complete",self,"drone_shutdown_complete")
	drone.show_id()
	
	print("Root game node ready!")
	print("Starting intro wipe")
	background.wipe_in()
	
func _process(delta):
	if Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_bg_in"):
		background.wipe_in()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_bg_out"):
		background.wipe_out()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_mus_cycle"):
		music.change_music()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_game_over"):
		game_over_1()
		
func game_over_1():
	background.game_over_1()
	music.game_over_1()
	camera.game_over_1()
	drone.game_over_1()
	
func drone_shutdown_complete():
	camera.game_over_2()
	drone.game_over_2()
	music.game_over_2()
	get_tree().get_root().get_child(0).get_node("GameOverText").visible = true
		
func setup_level(difficulty: int):
	# This function tears down and sets up a level each time it is called.
		# Spawn floor tiles.
		# Remove a random floor tiles.
		# Adds tasks to complete.
		# Add wall tiles.
	print("Beginning level setup.")

