extends AudioStreamPlayer

var songs: Array = [
	preload("res://mus/bawk.ogg"),
	preload("res://mus/bawk (alternate).ogg"),
	preload("res://mus/clicker training.ogg"),
	preload("res://mus/descend deeper.ogg"),
	preload("res://mus/nanite slurry.ogg"),
	preload("res://mus/numbers game.ogg"),
	preload("res://mus/respite.ogg"),
	preload("res://mus/task assignment.ogg"),
	preload("res://mus/victory lap.ogg"),
	preload("res://mus/welcome2hive.ogg")
	]

func change_music():
	stream = songs[randi() % songs.size()]
	play()
