extends Camera

var follow_target: Spatial
export var offset: Vector3
export var wallhug_offset: Vector3 = Vector3(0,2,-3)
export var game_over_offset: Vector3 = Vector3(0,0,0)
export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false
onready var raycast: RayCast = get_node("../RayCast")
onready var drone: KinematicBody = get_parent().get_parent().drone

func _ready():
	raycast.add_exception(drone)
	
func _process(delta):
	
	if game_over:
		translation = lerp(translation, follow_target.get_global_transform().origin + game_over_offset, 0.05)
		rotation_degrees = lerp(rotation_degrees, Vector3(0,0,0), 0.05)
		follow_target.rotation_degrees.y = lerp(follow_target.rotation_degrees.y, game_over_rotation_y, 0.05)
	
	if not active:
		return
	
	if follow_target:
			var new_translation = follow_target.get_global_transform().origin + offset
			raycast.translation = follow_target.get_global_transform().origin + Vector3(0,0,-0.1)
			if raycast.is_colliding():
				var drone_pos = follow_target.get_global_transform().origin
				var ray_length = raycast.get_cast_to().z
				var coll_pos = raycast.get_collision_point()
				var norm_min = coll_pos.z - ray_length
				
				# HOW 2 NORMALIZE
				# value - min / max - min
				# AND REMEMBER SCALE AFFECTS RAYCAST LENGTH
				# SO PUT THE RAYCAST ON YOUR CAMERA AND NOT THE OBJECT
				# SO YOU DON'T HAVE TO WORRY ABOUT SCALING
				
				
				new_translation += lerp(Vector3(0,0,0), wallhug_offset, (drone_pos.z - norm_min) / (coll_pos.z - norm_min))
			else:
				look_at(follow_target.get_global_transform().origin, Vector3(0,1,0))
	
			translation = lerp(translation, new_translation, 0.1)
			
	

func game_over_1():
	# switch to layer so only drone is visible.
	print("Camera game over func.")
	active = false
	cull_mask = 2
	
func game_over_2():
	game_over = true
