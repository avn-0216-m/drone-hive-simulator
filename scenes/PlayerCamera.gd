extends Camera3D

@onready var target = get_node("../Player")

var offset_normal = Vector3(0,4,6)
var offset_south: Vector3 = Vector3(0,10,3)
var offset_north: Vector3 = Vector3(0,7,9)
var target_pos = Vector3(0,0,0)

func _process(delta):
	if target.south_ray.is_colliding():
		target_pos = target.position + offset_south
	elif target.north_ray.is_colliding():
		target_pos = target.position + offset_north
	else:
		target_pos = target.position + offset_normal
		
	position = lerp(position, target_pos, 0.1)
	look_at(target.position)
