extends Camera

export var offset: Vector3 = Vector3(0,4,6)
export var wallhug_offset: Vector3 = Vector3(0,1,7)
export var game_over_offset: Vector3 = Vector3(0,0,0)
export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false
onready var raycast: RayCast = get_node("../WallhugRaycast")
onready var drone: KinematicBody = get_parent().get_parent().get_node("Drone")
onready var timer: Timer = get_node("../../TransitionTimers/TransitionMid")
var wall_mat: Material
var extern_mat: Material # Material for external corner.
var peephole_max_radius: int = 400
onready var no_walls_camera = get_node("../Viewport/NoWallsCamera")
var orbit_max = rad2deg(cos(deg2rad((360)))) * 0.1

enum State {LOCKED, MAIN, WALL_HUG, GAME_OVER, TRANSITION, ORBIT}
var current_state = State.MAIN
	
func _process(delta):
	
	if raycast.is_colliding() and current_state == State.MAIN:
		current_state = State.WALL_HUG
	elif !raycast.is_colliding() and current_state == State.WALL_HUG:
		current_state = State.MAIN
		
	var peephole_radius = wall_mat.get_shader_param("radius")
	if peephole_radius == null:
		peephole_radius = 0
	
	match(current_state):
		State.LOCKED:
			return
		State.MAIN:
			translation = lerp(translation, drone.get_global_transform().origin + offset, 0.1)
			raycast.translation = drone.get_global_transform().origin
			
			# Close peephole.
			var new_radius = lerp(peephole_radius, 0, 0.2)
			wall_mat.set_shader_param("radius", new_radius)
			extern_mat.set_shader_param("radius", new_radius)
			
			look_at(drone.get_global_transform().origin, Vector3(0,1,0))
		State.WALL_HUG:
			translation = lerp(translation, drone.get_global_transform().origin + wallhug_offset, 0.1)
			raycast.translation = drone.get_global_transform().origin
			var new_circle_center = unproject_position(drone.get_global_transform().origin)
			wall_mat.set_shader_param("circle_center", new_circle_center)
			extern_mat.set_shader_param("circle_center", new_circle_center)
			var new_radius = lerp(peephole_radius, peephole_max_radius, 0.05)
			wall_mat.set_shader_param("radius", new_radius)
			extern_mat.set_shader_param("radius", new_radius)
			look_at(drone.get_global_transform().origin, Vector3(0,1,0))
		State.GAME_OVER:
			translation = lerp(translation, drone.get_global_transform().origin + game_over_offset, 0.05)
			rotation_degrees = lerp(rotation_degrees, Vector3(0,0,0), 0.05)
			drone.rotation_degrees.y = lerp(drone.rotation_degrees.y, game_over_rotation_y, 0.05)
		State.TRANSITION:
			print(translation)
			translation = drone.get_global_transform().origin + Vector3(0,0,orbit_max)
			look_at(drone.get_global_transform().origin, Vector3(0,1,0))
			wall_mat.set_shader_param("radius", 0)
			extern_mat.set_shader_param("radius", 0)
		State.ORBIT:
			#var magnitude = lerp(0.2, 0.2, (timer.wait_time - timer.time_left) / timer.wait_time)
			translation = drone.get_global_transform().origin
			translation.z += rad2deg(cos(deg2rad((timer.wait_time - timer.time_left) / timer.wait_time * 360))) * 0.1
			translation.x += rad2deg(sin(deg2rad((timer.wait_time - timer.time_left) / timer.wait_time * 360))) * 0.1
			look_at(drone.get_global_transform().origin, Vector3(0,1,0))
			

func game_over_1():
	# switch to layer so only drone is visible.
	print("Camera game over func.")
	active = false
	cull_mask = 4
	
func game_over_2():
	game_over = true
