extends Pickup
class_name Anna

var jump: Vector3 = Vector3(0,0,0) # Jump velocity.

export var jump_force: float = 12
export var jump_length: float = 15

var skittishness: int = 10 # How likely you are to grab Anna.

signal spawn_level_obj(inst)

export(float, 0, 5) var jump_time = 1
export(float, 0, 5) var peck_time = 4
export(float, 0, 5) var bob_time = 2
export(float, 0, 5) var idle_time = 1
export(float, 0, 5) var flap_time = 4
export(float, 0, 10) var sit_time = 8
export var jump_interpolate_weight: float = 0.05
export var jump_length_linear_falloff: float = 0.05
onready var timer = get_node("Timer")
onready var sprite = get_node("AnnamatedSprite3D")
onready var battery_src = load("res://objects/Battery.tscn")

func _ready():
	gravity = 0.5
	sprite.animation = "bob"
	$Particles.emitting = false
	timer.connect("timeout",self,"new_action")
	._ready()
	
func body_nearby(body):
	if body is Drone:
		timer.set_paused(true)
		sprite.animation = "fly"
		gravity = 0
		var anim = $AnimationPlayer.get_animation("fly away")
		var idx = anim.find_track(".:translation:y")
		anim.track_set_key_value(idx, 0, translation.y)
		$AnimationPlayer.play("fly away")
		
func drop_battery():
	UI.log("Anna has left you a gift.")
	emit_signal("spawn_level_obj", battery_src.instance(), get_global_transform().origin)

func _physics_process(delta):
	
	if skip_process:
		return
	
	jump.y = apply_gravity(jump)
	move_and_slide(jump)
	if is_on_floor():
		jump.x = 0
		jump.z = 0
	else:
		if jump.x < 0:
			jump.x += jump_length_linear_falloff
		elif jump.x > 0:
			jump.x -= jump_length_linear_falloff

		if jump.z < 0:
			jump.z += jump_length_linear_falloff
		elif jump.z > 0:
			jump.z -= jump_length_linear_falloff
	
func new_action():
	if sprite.animation == "sit":
		sprite.animation = "stand"
		sprite.frame = 0
		timer.wait_time = 1
		timer.start()
		return
	jump = Vector3(0,0,0)
	randomize()
	match(randi() % 10):
		0: # Jump right.
			jump = Vector3(jump_length, jump_force, 0)
			timer.wait_time = jump_time
			sprite.flip_h = true
			sprite.animation = "jump"
			sprite.frame = 0
		1: # Jump left.
			jump = Vector3(-jump_length, jump_force, 0)
			timer.wait_time = jump_time
			sprite.flip_h = false
			sprite.animation = "jump"
			sprite.frame = 0
		2: # Jump down.
			jump = Vector3(0, jump_force, -jump_length)
			timer.wait_time = jump_time
			sprite.animation = "jump"
			sprite.frame = 0
		3: # Jump up.
			jump = Vector3(0, jump_force, jump_length)
			timer.wait_time = jump_time
			sprite.animation = "jump"
			sprite.frame = 0
		4: # Peck
			timer.wait_time = peck_time
			sprite.animation = "peck"
			sprite.frame = 0
		5: # Flap
			timer.wait_time = flap_time
			sprite.animation = "flap"
			sprite.frame = 0
		6: # Sit
			timer.wait_time = sit_time
			sprite.animation = "sit"
			sprite.frame = 0
		_: # Bob
#			timer.wait_time = bob_time
			sprite.animation = "bob"
			sprite.frame = 0
	timer.start()

func interact(interactor):
	$Chirp.play(0)
	if randi() % skittishness == 0 or true:
		return .interact(interactor)
	UI.log("Anna slips right out of your hands.")
	return null
	
func on_pickup():
	UI.log("Anna was nabbed!")
#	$AnimationPlayer.stop(true)
	
func on_drop():
	UI.log("Anna was released. Bye bye Anna!")
	var anim = $AnimationPlayer.get_animation("fly away")
	var idx = anim.find_track(".:translation:y")
	anim.track_set_key_value(idx, 0, translation.y)
	$AnimationPlayer.seek(0.3)
	$AnimationPlayer.play("fly away")
