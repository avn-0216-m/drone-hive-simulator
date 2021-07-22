extends AudioStreamPlayer

var game_node: Node = get_parent()
var songs: Array = [] # Contains arrays of intro-loop pairs. [0] = intro, [1] = loop.
var song_index: int = -1
var playing_intro: bool = false
var music_path: String = "res://mus/level/"
onready var game_over_music = load("res://mus/bawk.ogg")

func _ready():
	# Load all available songs in the level mus directory to the songs array.
	print("Loading music.")
	var dir: Directory = Directory.new()
	if dir.open(music_path) == OK:
		print("Music directory opened.")
		dir.list_dir_begin() # Inits the file reader stream.
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "ogg" and not file_name.ends_with("intro.ogg"):
				var audio_stream: AudioStream = load(music_path + file_name)
				var audio_stream_intro: AudioStream = load(music_path + file_name.get_basename() + " intro." + file_name.get_extension()) # Attempt to find an intro track if there is one
				if audio_stream_intro != null:
					print("Loaded " + file_name + " intro.")
				songs.append([audio_stream_intro, audio_stream])
				print("Loaded " + file_name)
			file_name = dir.get_next()
		print("Finished loading songs.")
		dir.list_dir_end() # Closes file reader stream.
	else:
		print("Failed to open music directory.")
		
	# Connect "finished" signal with music restart function
	connect("finished", self, "stream_finished")
	print("In-game music node ready.")
	
func stream_finished():
	print("Audio stream finished.")
	if playing_intro:
		print("Intro complete, starting loop.")
		stream = songs[song_index][1]
		playing_intro = false
	play()

func change_music():
	song_index += 1
	if songs == []:
		print("Couldn't change music. No songs loaded.")
		return
	print("Changing music.")
	if song_index >= len(songs):
		song_index = 0
	if songs[song_index][0] != null:
		playing_intro = true
		stream = songs[song_index][0]
		print("Playing song intro.")
	else:
		stream = songs[song_index][1]
	play()
