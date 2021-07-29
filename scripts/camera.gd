extends Camera

var follow_target: Spatial
export var offset: Vector3
export var max_height: float
export var raycast_offset: Vector3
export var game_over_offset: Vector3 = Vector3(0,0,0)
export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false

func _ready():
	pass # Replace with function body.
	
func _process(delta):
	
	if game_over:
		translation = lerp(translation, follow_target.get_global_transform().origin + game_over_offset, 0.1)
		rotation_degrees = lerp(rotation_degrees, Vector3(0,0,0), 0.1)
	
	if not active:
		return
	
	if follow_target:
		translation = lerp(translation, follow_target.get_global_transform().origin + offset, 0.1)
		look_at(follow_target.get_global_transform().origin, Vector3(0,1,0))
	else:
		print("Adding raycast to camera follow target")
		var new_raycast: RayCast = RayCast.new()
		new_raycast.set_name("CameraRaycast")
		follow_target.add_child(new_raycast)

func game_over_1():
	# switch to layer so only drone is visible.
	print("Camera game over func.")
	active = false
	cull_mask = 2
	
func game_over_2():
	game_over = true
