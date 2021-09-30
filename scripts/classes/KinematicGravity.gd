extends KinematicBody

class_name KinematicGravity

var velocity = Vector3(0,0,0)
export var gravity = 1 # How fast the max fall speed is reached.
export var max_fall_speed = 30

func apply_gravity(velocity) -> float:
	
	move_and_slide(Vector3(0,-0.1,0))
	
	var grounded = is_on_floor()

	velocity.y -= gravity
	if grounded and velocity.y  <= 0:
		velocity.y  = -0.1
	return max(velocity.y, -max_fall_speed)
