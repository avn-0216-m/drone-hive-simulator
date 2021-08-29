extends Node

signal level_complete

var tiles: Array = []

enum State {PLAYING, TRANSITION}
var current_state = State.PLAYING

export var previous_level_transition_curve: Curve
export var new_level_transition_curve: Curve

onready var level_transition_timer = get_node("LevelTransitionTimer")

onready var music = get_node("Music")
onready var level_src = load("res://objects/Level.tscn")
onready var background = get_tree().get_root().get_child(0).get_node("Background")
onready var camera = get_node("CameraContainer/MainCamera")
onready var drone: KinematicBody = get_node("Drone")
var difficulty: int = 0

# Level transition variables
var new_level_max_height_down = Vector3(0,-10,0)
var previous_level_max_height_up = Vector3(0,10,0)

var previous_level = null
var current_level = null

func _ready():
	print("Assigning camera.")
	camera.follow_target = drone
	
	drone.connect("shutdown_complete",self,"drone_shutdown_complete")
	drone.show_id()
	
	level_transition_timer.connect("timeout",self,"level_transition_complete")
	
	print("Root game node ready!")
	print("Starting intro wipe")
	first_level()
	#music.change_music()
	
func _process(delta):
	if Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_bg_in"):
		background.wipe_in()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_bg_out"):
		background.wipe_out()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_mus_cycle"):
		music.change_music()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_game_over"):
		game_over_1()
	elif Input.is_action_pressed("debug_hotkey") and Input.is_action_just_pressed("debug_drone_hearts"):
		drone.show_icon()
		drone.icon_display.frame = 3
		
	match(current_state):
		State.PLAYING:
			pass
		State.TRANSITION:
			
			var time_passed = level_transition_timer.wait_time - level_transition_timer.time_left
			current_level.translation = lerp(
				new_level_max_height_down,
				Vector3(0,0,0),
				new_level_transition_curve.interpolate(time_passed / level_transition_timer.wait_time))
			if previous_level != null:
				print(previous_level.translation)
				previous_level.translation = lerp(
					previous_level_max_height_up,
					Vector3(0,0,0),
					previous_level_transition_curve.interpolate(time_passed / level_transition_timer.wait_time))
			
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
		
func first_level():
	var level = level_src.instance()
	level.difficulty = 0
	level.name = "Level"
	add_child(level)
	current_level = level
		
func new_level():
	
	var level = level_src.instance()
	level.difficulty = difficulty
	
	level.name = "Level"
	previous_level = current_level
	current_level = level
	if previous_level != null:
		previous_level.name = "oldLevel"
	add_child(level)
	# Set translation after adding child otherwise multimeshes break.
	level.translation = new_level_max_height_down
	
	level_transition_timer.start()
	current_state = State.TRANSITION
	
	
	
	#drone.translation = level.gridmap.map_to_world(level.start_tile.x, level.start_tile.y, level.start_tile.z) + Vector3(0,3,0)
	#camera.translation = drone.translation

func level_transition_complete():
	if previous_level != null:
		previous_level.queue_free()
		pass
	current_level.translation = Vector3(0,0,0)
	current_state = State.PLAYING
	drone.immobile = false
