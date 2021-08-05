extends KinematicBody

signal shutdown_complete

onready var icon_display: Sprite3D = get_node("Display/Icon")
onready var id_display: Spatial = get_node("Display/ID")
onready var display_container: Spatial = get_node("Display")
onready var sprite: AnimatedSprite3D = get_node("Body")

onready var sfx: AudioStreamPlayer = get_node("SFX")
onready var shutdown: AudioStream = load("res://sfx//shutdown3.ogg")

var point_of_death: Vector3 = Vector3(0,0,0)

var id: int = 0000
var headbob_offset: Vector2 = Vector2(2.0, 1.9) #y if head is dipped, else x.
var velocity: Vector3 = Vector3(0,0,0)
var speed: float = 5

func _ready():
	sfx.connect("finished", self, "sfx_complete")
	set_id(5890)
	
func set_id(new_id: int):
	if id > 9999 or id < 0:
		return
	id = new_id
	var id_string: String = str(id)
	id_display.get_node("ID1").frame = int(id_string.left(1))
	id_display.get_node("ID2").frame = int(id_string.left(2))
	id_display.get_node("ID3").frame = int(id_string.left(3))
	id_display.get_node("ID4").frame = int(id_string.left(4))
	
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

func _process(delta):
	
	velocity = Vector3(0,0,0)
	
	# Get inputs, set velocity
	if Input.is_action_pressed("move_left"):
		velocity.x = -1 * speed
	if Input.is_action_pressed("move_right"):
		velocity.x = 1 * speed
	if Input.is_action_pressed("move_up"):
		velocity.z = -1 * speed
	if Input.is_action_pressed("move_down"):
		velocity.z = 1 * speed
		
	move_and_slide(velocity)
	
	# Calculate headbob
	if sprite.frame % 2 != 0:
		display_container.translation.y = headbob_offset.y
	else:
		display_container.translation.y = headbob_offset.x
		
func game_over_1():
	point_of_death = get_global_transform().origin
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
