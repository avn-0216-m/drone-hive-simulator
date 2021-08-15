extends Camera

var follow_target: Spatial
export var offset: Vector3
export var wallhug_offset: Vector3 = Vector3(0,2,-3)
export var game_over_offset: Vector3 = Vector3(0,0,0)
export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false
onready var raycast: RayCast = get_node("../WallhugRaycast")
onready var drone: KinematicBody = get_parent().get_parent().get_node("Drone")
var wall_mat: Material
var extern_mat: Material # Material for external corner.
var peephole_max_radius: int = 400
onready var no_walls_camera = get_node("../Viewport/NoWallsCamera")


func _ready():
	wall_mat = get_node("../../Level/Multimeshes/Walls").multimesh.mesh.surface_get_material(0)
	extern_mat = get_node("../../Level/Multimeshes/ExternalCorners").multimesh.mesh.surface_get_material(0)
	
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
			
			var peephole_radius = wall_mat.get_shader_param("radius")
			if peephole_radius == null:
				peephole_radius = 0
				
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
				
				
				#new_translation += lerp(Vector3(0,0,0), wallhug_offset, (drone_pos.z - norm_min) / (coll_pos.z - norm_min))
				new_translation += wallhug_offset
				
				var new_circle_center = unproject_position(drone.get_global_transform().origin)
				wall_mat.set_shader_param("circle_center", new_circle_center)
				extern_mat.set_shader_param("circle_center", new_circle_center)
				
				var new_radius = lerp(peephole_radius, peephole_max_radius, 0.05)
				wall_mat.set_shader_param("radius", new_radius)
				extern_mat.set_shader_param("radius", new_radius)
			else:
				var new_radius = lerp(peephole_radius, 0, 0.2)
				wall_mat.set_shader_param("radius", new_radius)
				extern_mat.set_shader_param("radius", new_radius)
				pass

			look_at(follow_target.get_global_transform().origin, Vector3(0,1,0))
			translation = lerp(translation, new_translation, 0.05)
			no_walls_camera.transform = get_global_transform()
			
			
	

func game_over_1():
	# switch to layer so only drone is visible.
	print("Camera game over func.")
	active = false
	cull_mask = 4
	
func game_over_2():
	game_over = true
