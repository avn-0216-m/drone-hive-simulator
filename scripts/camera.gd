extends Camera

# camera offsets
var normal_offset: Vector3 = Vector3(0,4,6)
var wallhug_offset: Vector3 = Vector3(0,1,7)
var game_over_offset: Vector3 = Vector3(3,0,6)
var transition_offset: Vector3 = Vector3(0,0,0)

# Force override look_at, if false, camera will not rotate to face drone
# even if state is supposed to look at drone.
var look_at = true

var peephole_current_radius: int = 0
var peephole_max_radius: int = 400

export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false
onready var raycast: RayCast = get_node("../WallhugRaycast")
onready var drone: KinematicBody = get_parent().get_parent().get_node("Drone")

var wall_mat: Material
var extern_mat: Material # Material for external corner mesh.
var intern_mat: Material # Material for internal corner mesh.

enum State {LOCKED, MAIN, WALL_HUG, GAME_OVER, TRANSITION, ORBIT}
var current_state = State.MAIN

func _ready():
	translation = drone.translation + normal_offset
	
func _process(delta):
	
	var offset = null
	
	if raycast.is_colliding() and current_state == State.MAIN:
		current_state = State.WALL_HUG
	elif !raycast.is_colliding() and current_state == State.WALL_HUG:
		current_state = State.MAIN
		
	var peephole_current_radius = wall_mat.get_shader_param("radius")
		
	# Set camera offset based on state.
	match(current_state):
		State.LOCKED:
			return
		State.MAIN:
			offset = normal_offset
		State.WALL_HUG, State.TRANSITION:
			offset = wallhug_offset
		State.ORBIT, State.GAME_OVER:
			offset = game_over_offset
	
	# handle peephole radius
	match(current_state):
		State.WALL_HUG:
			var new_circle_center = unproject_position(drone.get_global_transform().origin)
			wall_mat.set_shader_param("circle_center", new_circle_center)
			extern_mat.set_shader_param("circle_center", new_circle_center)
			intern_mat.set_shader_param("circle_center", new_circle_center)
			var new_radius = lerp(peephole_current_radius, peephole_max_radius, 0.05)
			wall_mat.set_shader_param("radius", new_radius)
			extern_mat.set_shader_param("radius", new_radius)
			intern_mat.set_shader_param("radius", new_radius)
		_:
			var new_circle_center = unproject_position(drone.get_global_transform().origin)
			wall_mat.set_shader_param("circle_center", new_circle_center)
			extern_mat.set_shader_param("circle_center", new_circle_center)
			intern_mat.set_shader_param("circle_center", new_circle_center)
			var new_radius = lerp(peephole_current_radius, 0, 0.15)
			wall_mat.set_shader_param("radius", new_radius)
			extern_mat.set_shader_param("radius", new_radius)
			intern_mat.set_shader_param("radius", new_radius)
			
	# Update translation if offset was decided.
	if offset != null:
		translation = lerp(translation, drone.get_global_transform().origin + offset, 0.1)
	if look_at and current_state in [State.MAIN, State.WALL_HUG, State.TRANSITION]:
		look_at(drone.get_global_transform().origin, Vector3(0,1,0))
		
	raycast.translation = drone.get_global_transform().origin


func game_over_1():
	# switch to layer so only drone is visible.
	print("Camera game over func.")
	active = false
	cull_mask = 4
	
func game_over_2():
	game_over = true
