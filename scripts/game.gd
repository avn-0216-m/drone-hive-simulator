extends Node

signal level_complete

var tiles: Array = []

enum State {PLAYING, TRANSITION_OUT, TRANSITION_MID, TRANSITION_IN}
var current_state = State.PLAYING

onready var music = get_node("Music")
onready var level = get_node("Level")
onready var storage_box_src = preload("res://objects/StorageBox.tscn")
onready var background = get_tree().get_root().get_node("Main/Composite/Background")
onready var camera = get_node("Camera")
onready var player: KinematicBody = get_node("Player")
var difficulty: int = 0

func _ready():
	$AnimationPlayer.connect("animation_finished",self,"animation_finished")
	player.show_id()
	background.wipe_in()
	
	#level.new_level()
	
	#music.change_music()
	
func wipe_out():
	background.wipe_out()
	
func wipe_in():
	background.wipe_in()

func new_level():
	difficulty += 1
	print("New level")
	$AnimationPlayer.play("new_level")


func respawn_drone(player):
	UI.log("How'd you get down there? Silly little thing.")
	player.translation = level.respawn_point

func spawn_level_obj(inst, translation = Vector3(0,0,0)):
	print("hello world")
	print(inst)
	inst.translation = translation
	get_node("Level/Objects").add_child(inst)
