extends Interactable

var frame = 0
var wiggle_magnitude = 0.5
var wiggle_speed = 0.05
onready var mesh = get_node("MeshInstance")

func _process(delta):
	frame += 1 * wiggle_speed
	mesh.translation.y = 0 + sin(frame) * wiggle_magnitude
	mesh.rotation_degrees.y += 1
	if frame > 360:
		frame = 0

func _ready():
	gravity = 0.3
	max_fall_speed = 15

func interact(interactor):
	interactor.recharge()
	queue_free()
