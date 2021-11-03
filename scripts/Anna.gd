extends Pickup

# She used to program my brain, now it's the other way around.
# haha.

var jump: Vector3 # Jump velocity.

export var jump_force: float = 12
export var jump_length: float = 15

var flying = false
var fly_away_velocity = Vector3(0,3,0)
var floor_test = Vector3(0,-0.1,0)

export(float, 0, 5) var jump_time = 1
export(float, 0, 5) var peck_time = 4
export(float, 0, 5) var bob_time = 2
export(float, 0, 5) var idle_time = 1
export(float, 0, 5) var flap_time = 4
export(float, 0, 10) var sit_time = 8
export var jump_interpolate_weight: float = 0.05
export var jump_length_linear_falloff: float = 0.05
onready var timer = get_node("Timer")
onready var area = get_node("Annarea")
onready var sprite = get_node("AnnamatedSprite3D")
onready var battery_src = load("res://objects/Battery.tscn")

func _ready():
	gravity = 0.5
	timer.connect("timeout",self,"new_action")
	area.connect("body_entered", self, "something_near")
	
	icon = ImageTexture.new()
	var img = Image.new()
	img.load("res://sprites/anna/idle.png")
	icon.create_from_image(img, 0)
	
	icon_scale = Vector3(2,2,1)
	
func something_near(body):
	if body.name == "Drone":
		flying == true
		timer.set_paused(true)
		sprite.animation = "fly"
		gravity = -0.2
	
func _physics_process(delta):
	
	if skip_process:
		return
	
	if flying:
		fly_away_velocity.y = apply_gravity(fly_away_velocity)
		move_and_slide(fly_away_velocity, Vector3(0,1,0))
	else:
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
	
	if translation.y > 10.8:
		return
		
		# TODO: don't spawn battery based on height,
		# instead start a timer and delete+spawn when it ends.
		
		var gift = battery_src.instance()
		gift.translation = get_global_transform().origin
		get_tree().get_root().get_node("Main/Viewport/Game").add_child(gift)
		queue_free()
	
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
	if randi() % 10 == 0:
		print("caught!")
		.interact(interactor)
