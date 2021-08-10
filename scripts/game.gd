extends Node

signal level_complete

var tiles: Array = []

onready var music = get_node("Music")
onready var grid_map = get_node("GridMap")
onready var background = get_tree().get_root().get_child(0).get_node("Background")
onready var camera = get_node("CameraContainer/Camera")
onready var drone: KinematicBody = get_node("Drone")
var difficulty: int = 10

func _ready():
	print("Assigning camera.")
	camera.follow_target = drone
	
	drone.connect("shutdown_complete",self,"drone_shutdown_complete")
	drone.show_id()
	
	print("Root game node ready!")
	print("Starting intro wipe")
	background.wipe_in()
	new_level()
	
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
		
func new_level():
	print("Beginning level setup.")
	grid_map.new_level(difficulty)
	drone.translation = grid_map.map_to_world(grid_map.start_tile.x, grid_map.start_tile.y, grid_map.start_tile.z) + Vector3(0,5,0) + grid_map.get_global_transform().origin
	camera.translation = drone.translation
