extends Interactable
class_name Battery

var frame = 0
var wiggle_magnitude = 0.5
var wiggle_speed = 0.05
@onready var mesh = get_node("MeshInstance3D")

func _process(delta):
	frame += 1 * wiggle_speed
	mesh.position.y = 0 + sin(frame) * wiggle_magnitude
	mesh.rotation_degrees.y += 1
	if frame > 360:
		frame = 0

func _ready():
	gravity = 0.3
	max_fall_speed = 15

func interact(interactor):
	if interactor is Drone:
		interactor.battery.recharge(50)
	queue_free()
