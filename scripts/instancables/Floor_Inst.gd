extends Instancable
class_name Floor

func _ready():
	path = "res://objects/tiles/Floor.tscn"
	testvar = "IMFLOOR"

static func instance():
	# add body and add position data to floor multimesh.
	print("beep")
	return 3000
