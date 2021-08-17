extends Spatial

# She used to program my brain, now it's the other way around.
# haha.

var hop_distance_per_frame = 1
var hop_height_magnitude = 1
var base: Vector3
export var jump_height_curve: Curve
onready var timer = get_node("Timer")

func _ready():
	timer.connect("timeout",self,"new_action")
	
func _process(delta):
	return
	
func new_action():
	base = translation
	randomize()
	match(randi() % 10):
		0:
			print("beep")
		1:
			print("boop")
		2:
			print("bweep")
		3:
			print("bwoop")
		4:
			print("bawk")
		_:
			print("awa")
	timer.start()