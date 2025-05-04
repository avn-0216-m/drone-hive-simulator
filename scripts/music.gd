extends AudioStreamPlayer

var level_songs: Array = [
	preload("res://mus/clicker training.ogg"),
	preload("res://mus/descend deeper.ogg"),
	preload("res://mus/nanite slurry.ogg"),
	preload("res://mus/task assignment.ogg"),
	preload("res://mus/victory lap.ogg"),
	preload("res://mus/stories of stardomme.ogg"),
	preload("res://mus/phoenix.ogg"),
	preload("res://mus/welcome2hive.ogg"),
	preload("res://mus/respite.ogg")
	]

@onready var game_over = preload("res://mus/bawk.ogg")
@onready var game_over_alt = preload("res://mus/bawk (alternate).ogg")
@onready var id_select = preload("res://mus/numbers game.ogg")
@onready var upgrades = preload("res://mus/respite.ogg")
	
func change_music():
	stream = level_songs[randi() % level_songs.size()]
	play()
