extends Camera

var follow_target: Spatial
export var offset: Vector3
export var max_height: float
export var raycast_offset: Vector3

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	if follow_target:
		translation = lerp(translation, follow_target.get_global_transform().origin + offset, 0.1)
		look_at(follow_target.get_global_transform().origin, Vector3(0,1,0))
	
	if follow_target.get_node("CameraRaycast"):
		follow_target.get_node("CameraRaycast").cast_to = raycast_offset
		var collision = follow_target.get_node("CameraRaycast").get_collider()
		if collision == null:
			return
		print(collision.collision_layer)
		
	else:
		print("Adding raycast to camera follow target")
		var new_raycast: RayCast = RayCast.new()
		new_raycast.set_name("CameraRaycast")
		follow_target.add_child(new_raycast)
