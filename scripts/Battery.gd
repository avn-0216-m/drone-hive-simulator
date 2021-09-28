extends KinematicGravity

var frame = 0
var wiggle_magnitude = 0.5
var wiggle_speed = 0.05
var velocity = Vector3(0,0,0)
onready var mesh = get_node("MeshInstance")

func _process(delta):
	frame += 1 * wiggle_speed
	mesh.translation.y = 0 + sin(frame) * wiggle_magnitude
	mesh.rotation_degrees.y += 1
	if frame > 360:
		frame = 0
		
	move_and_slide(Vector3(0,-0.1,0), Vector3(0,1,0))
	var grounded = is_on_floor()
	
	velocity.y = apply_gravity(velocity, grounded).y
	move_and_slide(velocity)
	
func _ready():
	gravity = 0.3
	max_fall_speed = 15