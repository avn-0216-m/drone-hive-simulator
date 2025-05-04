extends CharacterBody3D

class_name KinematicGravity

var velocity_other = Vector3(0,0,0)
var gravity = 9.8 # How fast the max fall speed is reached.
var max_fall_speed = 30
@export var skip_process = false

func apply_gravity(velocity) -> float:
	
	set_velocity(Vector3(0,-0.1,0))
	set_up_direction(Vector3.UP)
	move_and_slide()
	
	var grounded = is_on_floor()

	velocity_other.y -= gravity
	if grounded and velocity_other.y  <= 0:
		velocity_other.y  = -0.1
	return max(velocity_other.y, -max_fall_speed)

func _process(delta):
	if skip_process:
		return
	velocity_other.y = apply_gravity(velocity_other)
	set_velocity(velocity_other)
	move_and_slide()
