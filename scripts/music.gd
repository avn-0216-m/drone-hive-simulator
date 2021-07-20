extends AudioStreamPlayer

var game_node: Node = get_parent()
var songs: Array = []
var song_index: int = 0
var music_path: String = "res://mus/"

func _ready():
	# Load all available songs in the mus directory to the songs array.
	print("Loading music.")
	var dir: Directory = Directory.new()
	if dir.open(music_path) == OK:
		print("Music directory opened.")
		dir.list_dir_begin() # Inits the file reader stream.
		var file_name: String = dir.get_next()
		while file_name != "":
			if file_name.get_extension() == "wav":
				var audio_stream: AudioStream = load(music_path + file_name)
				songs.append(audio_stream)
				print("Loaded " + file_name)
			file_name = dir.get_next()
		print("Finished loading songs.")
		dir.list_dir_end() # Closes file reader stream.
	else:
		print("Failed to open music directory.")
		
	# Connect "finished" signal with music restart function
	connect("finished", self, "restart_music")
	
func restart_music():
	print("Restarting music.")
	self.play()

func change_music(given_index: int = -1):
	if given_index != -1:
		song_index = given_index
	print("Changing music.")
	if song_index >= len(songs):
		song_index = 0
	self.stream = songs[song_index]
	self.play()
	song_index += 1
