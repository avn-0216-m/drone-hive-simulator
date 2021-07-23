extends Node

signal level_complete

var tiles: Array = []

onready var music_player = get_node("Music")
onready var grid_map = get_node("GridMap")

func _ready():
	print("Root game node ready!")
	music_player.change_music()
	music_player.change_music()
	music_player.change_music()

func setup_level(difficulty: int):
	# This function tears down and sets up a level each time it is called.
		# Spawn floor tiles.
		# Remove a random floor tiles.
		# Adds tasks to complete.
		# Add wall tiles.
	print("Beginning level setup.")

