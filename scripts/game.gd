extends Node

signal level_complete

var tiles: Array = []

enum State {PLAYING, TRANSITION_OUT, TRANSITION_MID, TRANSITION_IN}
var current_state = State.PLAYING

@onready var music = get_node("Music")
@onready var level = get_node("Level")
@onready var camera = get_node("Camera3D")
@onready var player: CharacterBody3D = get_node("Player")
var difficulty: int = 0

func _ready():
	$AnimationPlayer.connect("animation_finished", Callable(self, "animation_finished"))
	player.show_id()
	
	# Assign multimesh ref to camera obj
	#get_node("Camera").materials = (get_node("Level/Geometry").get_wall_materials())
	
	#level.new_level()
	
	#music.change_music()

func new_level():
	difficulty += 1
	print("New level")
	$AnimationPlayer.play("new_level")


func respawn_drone():
	UI.log("How'd you get down there? Silly little thing.")
	player.position = level.respawn_point

func spawn_level_obj(inst, position = Vector3(0,0,0)):
	print("hello world")
	print(inst)
	inst.position = position
	get_node("Level/Objects").add_child(inst)
