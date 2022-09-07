extends Camera

# camera offsets
var normal_offset: Vector3 = Vector3(0,4,6)
var close_south_offset: Vector3 = Vector3(0,1,7)
var close_north_offset: Vector3 = Vector3(0,7,9)
var game_over_offset: Vector3 = Vector3(3,0,6)
var transition_offset: Vector3 = Vector3(0,0,0)

# Force override look_at, if false, camera will not rotate to face drone
# even if state is supposed to look at player.
var look_at = true

var circle_center: Vector2 = Vector2(0,0)
var peephole_radius: int = 0
var peephole_max_radius: int = 400

export var game_over_rotation_y: float = 45
var active: bool = true
export var game_over: bool = false
onready var player: KinematicBody = get_tree().get_root().get_node("Root/Composite/GameTexture/Viewport/Game/Player")
onready var south_ray: RayCast = player.south_ray
onready var north_ray: RayCast = player.north_ray

onready var tween: Tween = get_node("PeepholeTween")

var materials: Array = []

enum State {LOCKED, NORMAL, CLOSE_SOUTH, CLOSE_NORTH}
var state = State.NORMAL
var previous_state = State.NORMAL

func handle_state_change(new_state: int):
	if new_state == State.CLOSE_SOUTH: 
		tween.interpolate_property(self, "peephole_radius", 0, peephole_max_radius, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()
	elif peephole_radius != 0:
		tween.interpolate_property(self, "peephole_radius", peephole_max_radius, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		tween.start()

func _ready():
	translation = player.translation + normal_offset
	
func _process(delta):

	# Handle state changes
	if south_ray.is_colliding():
		state = State.CLOSE_SOUTH
	elif north_ray.is_colliding():
		state = State.CLOSE_NORTH
	else:
		state = State.NORMAL

	if state != previous_state:
		handle_state_change(state)	
		
	circle_center = unproject_position(player.get_global_transform().origin)
	var offset: Vector3 = Vector3(0,0,0)
		
	# Set camera offset based on state.
	match(state):
		State.LOCKED:
			return
		State.NORMAL:
			offset = normal_offset
		State.CLOSE_NORTH:
			offset = close_north_offset
		State.CLOSE_SOUTH:
			offset = close_south_offset

	update_shader_params(materials, peephole_radius, circle_center)


	translation = lerp(translation, player.get_global_transform().origin + offset, 0.1)
	if look_at:
		look_at(player.get_global_transform().origin, Vector3(0,1,0))
		
	previous_state = state

func update_shader_params(materials: Array, radius: float, circle_center: Vector2):
	for material in materials:
		material.set_shader_param("radius", radius)
		material.set_shader_param("circle_center", circle_center)
