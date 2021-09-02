extends Node

signal level_complete

var tiles: Array = []

enum State {PLAYING, TRANSITION_OUT, TRANSITION_MID, TRANSITION_IN}
var current_state = State.PLAYING

export var previous_level_transition_curve: Curve
export var new_level_transition_curve: Curve

onready var trans_out_timer = get_node("TransitionTimers/TransitionOut")
onready var trans_mid_timer = get_node("TransitionTimers/TransitionMid")
onready var trans_in_timer = get_node("TransitionTimers/TransitionIn")

onready var music = get_node("Music")
onready var level_src = load("res://objects/Level.tscn")
onready var transition_pod_src = load("res://objects/Elevator.tscn")
onready var background = get_tree().get_root().get_child(0).get_node("Background")
onready var camera = get_node("CameraContainer/MainCamera")
onready var drone: KinematicBody = get_node("Drone")
var difficulty: int = 0

# Level transition variables
var new_level_max_height_down = Vector3(0,-20,0)
var previous_level_max_height_up = Vector3(0,20,0)

var previous_level = null
var current_level = null

func _ready():
	print("Assigning camera.")
	
	drone.connect("shutdown_complete",self,"drone_shutdown_complete")
	drone.show_id()
	
	trans_out_timer.connect("timeout",self,"transition_out_complete")
	trans_mid_timer.connect("timeout",self,"transition_mid_complete")
	trans_in_timer.connect("timeout",self,"transition_in_complete")
	
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
		State.TRANSITION_OUT:
			var time_passed = trans_out_timer.wait_time - trans_out_timer.time_left
			if previous_level != null:
				previous_level.translation = lerp(
					previous_level_max_height_up,
					Vector3(0,0,0),
					previous_level_transition_curve.interpolate(time_passed / trans_out_timer.wait_time))
		State.TRANSITION_MID:
			pass
		State.TRANSITION_IN:
			var time_passed = trans_in_timer.wait_time - trans_in_timer.time_left
			current_level.translation = lerp(
				new_level_max_height_down,
				Vector3(0,0,0),
				new_level_transition_curve.interpolate(time_passed / trans_in_timer.wait_time))
			
			
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
	level.type = level.LevelType.FIRST
	add_child(level)
	current_level = level
		
func new_level():
	
	difficulty += 1
	
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
	
	trans_out_timer.start()
	current_state = State.TRANSITION_OUT
	
	
	
	#drone.translation = level.gridmap.map_to_world(level.start_tile.x, level.start_tile.y, level.start_tile.z) + Vector3(0,3,0)
	#camera.translation = drone.translation

func transition_out_complete():
	print("Transition out complete.")
	current_state = State.TRANSITION_MID
	trans_mid_timer.start()
	camera.current_state = camera.State.TRANSITION

func transition_mid_complete():
	print("Transition mid complete.")
	current_state = State.TRANSITION_IN
	camera.current_state = camera.State.MAIN
	
	var elevator = get_node("Elevator")
	elevator.translation = current_level.gridmap.map_to_world(current_level.start_tile.x, current_level.start_tile.y, current_level.start_tile.z)
	drone.translation = elevator.get_node("DroneGoesHere").get_global_transform().origin
	
	trans_in_timer.start()
	
func transition_in_complete():
	print("Transition in complete.")
	if previous_level != null:
		previous_level.queue_free()
		pass
	drone.immobile = false
	current_state = State.PLAYING
	current_level.translation = Vector3(0,0,0)
	
	# Reparent the storagepod from Game node to the new level node.
	var transition_pod = transition_pod_src.instance()
	transition_pod.transform = get_node("Elevator").get_global_transform()
	transition_pod.drone = drone
	drone.immobile = false
	get_node("Level/Bodies").add_child(transition_pod)
	get_node("Elevator").queue_free()
