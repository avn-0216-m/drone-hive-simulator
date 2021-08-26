extends KinematicBody

signal shutdown_complete

onready var icon_display: Sprite3D = get_node("Display/Icon")
onready var id_display: Spatial = get_node("Display/ID")
onready var display_container: Spatial = get_node("Display")
onready var sprite: AnimatedSprite3D = get_node("Body")

onready var sfx: AudioStreamPlayer = get_node("SFX")
onready var shutdown: AudioStream = load("res:/sfx/shutdown3.ogg")
onready var sfx_battery: AudioStream = load("res://sfx/battery.ogg")

onready var pickup_area = get_node("PickupArea")
onready var battery = load("res://objects/Battery.tscn")

var id: String = "0000"
var headbob_offset: Vector2 = Vector2(2.0, 1.9) #y if head is dipped, else x.
var velocity: Vector3 = Vector3(0,0,0)
var speed: float = 5
const GRAVITY: Vector3 = Vector3(0,-7,0)

var active: bool = true

var move_up = 1
var move_down = 2
var move_left = 4
var move_right = 8
var interact = 16

func _ready():
	sfx.connect("finished", self, "sfx_complete")
	$FaceTimer.connect("timeout", self, "show_id")
	pickup_area.connect("body_entered", self, "pickup_in_range")
	set_id("0216")
	
func set_id(new_id: String):
	if int(id) > 9999 or int(id) < 0:
		return
	id = new_id
	id_display.get_node("ID1").frame = int(id.substr(0,1))
	id_display.get_node("ID2").frame = int(id.substr(1,1))
	id_display.get_node("ID3").frame = int(id.substr(2,1))
	id_display.get_node("ID4").frame = int(id.substr(3,1))
	
func toggle_face():
	if icon_display.visible == true:
		show_id()
	else:
		show_icon()

func show_id():
	icon_display.visible = false
	id_display.visible = true
	
func show_icon():
	icon_display.visible = true
	id_display.visible = false

func toggle_display():
	display_container.visible = !display_container.visible
	
func get_inputs() -> int:
	
	if !active:
		return 0
	
	var inputs = 0
	
	if Input.is_action_pressed("move_left"):
		inputs += move_left
	if Input.is_action_pressed("move_right"):
		inputs += move_right
	if Input.is_action_pressed("move_up"):
		inputs += move_up
	if Input.is_action_pressed("move_down"):
		inputs += move_down
	return inputs

func _process(delta):
	
	velocity = Vector3(0,0,0) + GRAVITY
	
	# Get inputs, set velocity
	var inputs = get_inputs()
	
	if inputs & move_right:
		velocity.x = 1 * speed
		sprite.rotation_degrees.y = 0
		display_container.translation = Vector3(0,1.9,0.1)
	if inputs & move_left:
		velocity.x = -1 * speed
		sprite.rotation_degrees.y = 180
		display_container.translation = Vector3(-0.5,1.9,0.1)
	if inputs & move_down:
		velocity.z = 1 * speed
	if inputs & move_up:
		velocity.z = -1 * speed

	# Check if drone should keep walking.
	sprite.playing = !(not inputs and (sprite.frame == 0 or sprite.frame == 2))

	# Calculate headbob
	if sprite.frame % 2 != 0:
		display_container.translation.y = headbob_offset.y
	else:
		display_container.translation.y = headbob_offset.x
		
	if velocity.z < 0:
		sprite.animation = "backward"
	else:
		sprite.animation = "forward"
		
	if sprite.animation == "backward":
		display_container.visible = false
	else:
		display_container.visible = true
		
func _physics_process(delta):
	move_and_slide(velocity)
		
func game_over_1():
	print("Drone game over")
	show_icon()
	icon_display.frame = 1
	sfx.stream = shutdown
	sfx.play()
	sprite.playing = false
	sprite.frame = 0

func game_over_2():
	sprite.playing = true
	icon_display.frame = 3

func sfx_complete():
	if sfx.stream == shutdown:
		print("Drone shutdown complete, emitting signal.")
		emit_signal("shutdown_complete")
		
func pickup_in_range(body):
	if body.get_filename() == battery.get_path():
		body.queue_free()
		sfx.stream = sfx_battery
		sfx.play()
		$BatteryParticles.one_shot = false
		$BatteryParticles.emitting = true
		$BatteryParticles.one_shot = true
		icon_display.frame = 3
		show_icon()
		$FaceTimer.start()
