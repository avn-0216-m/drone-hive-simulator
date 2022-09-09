extends KinematicBody

class_name KinematicGravity

var velocity = Vector3(0,0,0)
var gravity = 9.8 # How fast the max fall speed is reached.
var max_fall_speed = 30
var skip_process = false

func apply_gravity(velocity) -> float:
	
	move_and_slide(Vector3(0,-0.1,0), Vector3.UP)
	
	var grounded = is_on_floor()

	velocity.y -= gravity
	if grounded and velocity.y  <= 0:
		velocity.y  = -0.1
	return max(velocity.y, -max_fall_speed)

func _process(delta):
	if skip_process:
		return
	velocity.y = apply_gravity(velocity)
	move_and_slide(velocity)
