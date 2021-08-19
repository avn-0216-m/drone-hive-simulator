extends KinematicBody

class_name KinematicGravity

export var gravity = 1 # How fast the max fall speed is reached.
export var max_fall_speed = 30

func apply_gravity(velocity, grounded) -> Vector3:
	
	velocity.y -= gravity
	if grounded and velocity.y  <= 0:
		velocity.y  = -0.1
	velocity.y = max(velocity.y, -max_fall_speed)
	
	return velocity
