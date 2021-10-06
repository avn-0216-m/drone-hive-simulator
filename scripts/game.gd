extends Node

signal level_complete

var tiles: Array = []

enum State {PLAYING, TRANSITION_OUT, TRANSITION_MID, TRANSITION_IN}
var current_state = State.PLAYING

onready var music = get_node("Music")
onready var level_src = preload("res://objects/Level.tscn")
onready var storage_box_src = preload("res://objects/StorageBox.tscn")
onready var background = get_tree().get_root().get_node("Main/Background")
onready var camera = get_node("CameraContainer/MainCamera")
onready var drone: KinematicBody = get_node("Drone")
var difficulty: int = 10

var previous_level = null
var current_level = null

func _ready():
	
	drone.connect("shutdown_complete",self,"drone_shutdown_complete")
	$AnimationPlayer.connect("animation_finished",self,"animation_finished")
	drone.show_id()
	
	print("Root game node ready!")
	print("Starting intro wipe")
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
		
func new_level_old():
	
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
	camera.current_state = camera.State.TRANSITION
	current_state = State.TRANSITION_OUT
	
	#drone.translation = level.gridmap.map_to_world(level.start_tile.x, level.start_tile.y, level.start_tile.z) + Vector3(0,3,0)
	#camera.translation = drone.translation

func wipe_out():
	background.wipe_out()
	
func wipe_in():
	background.wipe_in()

func new_level():
	difficulty = 10
	print("New level")
	$AnimationPlayer.play("new_level")

func reposition_storage_box():
	var storage = get_node("StorageBox")
	storage.translation = get_node("Level").start_tile_pos
	drone.translation = storage.translation + Vector3(0,2,0)

func animation_finished(animation):
	if animation == "new_level":
		# Reparent StorageBox from Game node to new level node.
		print("transition done")
		var storage_box = storage_box_src.instance()
		storage_box.transform = get_node("StorageBox").get_global_transform()
		storage_box.drone = drone
		storage_box.current_state = storage_box.State.OUTPUT
		drone.immobile = false
		get_node("Level/Bodies").add_child(storage_box)
		get_node("StorageBox").queue_free()
