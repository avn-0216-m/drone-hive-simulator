extends KinematicBody

# She used to program my brain, now it's the other way around.
# haha.

var base: Vector3
var jump: Vector3

export var jump_height: float = 2
export var jump_length: float = 4

export(float, 0, 5) var jump_time = 1
export(float, 0, 5) var peck_time = 4
export(float, 0, 5) var bob_time = 2
export(float, 0, 5) var idle_time = 1
export(float, 0, 5) var flap_time = 4
export(float, 0, 10) var sit_time = 10

export var jump_height_curve: Curve
export var jump_length_curve: Curve
onready var timer = get_node("Timer")
onready var sprite = get_node("AnnamatedSprite3D")
onready var battery = load("res://objects/battery.tscn")

func _ready():
	timer.connect("timeout",self,"new_action")
	
func _process(delta):
	
	# TODO, use actual kinemannatic body stuff so she collides properly.
	
	if jump != Vector3(0,0,0):
		var offset = jump
		offset.x *= jump_length_curve.interpolate(timer.wait_time - timer.time_left)
		offset.z *= jump_length_curve.interpolate(timer.wait_time - timer.time_left)
		offset.y *= jump_height_curve.interpolate(timer.wait_time - timer.time_left)
		translation = base + offset
	if translation.y > 20:
		queue_free()
	
func new_action():
	if sprite.animation == "sit":
		sprite.animation = "stand"
		sprite.frame = 0
		timer.wait_time = 1
		timer.start()
	base = translation
	jump = Vector3(0,0,0)
	randomize()
	match(randi() % 10):
		0: # Jump right.
			jump = Vector3(jump_length, jump_height, 0)
			timer.wait_time = jump_time
			sprite.flip_h = true
			sprite.animation = "jump"
			sprite.frame = 0
		1: # Jump left.
			jump = Vector3(-jump_length, jump_height, 0)
			timer.wait_time = jump_time
			sprite.flip_h = false
			sprite.animation = "jump"
			sprite.frame = 0
		2: # Jump down.
			jump = Vector3(0, jump_height, -jump_length)
			timer.wait_time = jump_time
			sprite.animation = "jump"
			sprite.frame = 0
		3: # Jump up.
			jump = Vector3(0, jump_height, jump_length)
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
			timer.wait_time = bob_time
			sprite.animation = "bob"
			sprite.frame = 0
	timer.start()
