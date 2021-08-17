extends KinematicBody

var frame = 0
var base: Vector3
var magnitude = 0.5

func _process(delta):
	frame += 0.01
	translation.y = base.y + sin(frame) * magnitude
	rotation_degrees.y += 1
	if frame > 360:
		frame = 0

func _ready():
	base = translation
