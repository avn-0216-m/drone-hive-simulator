extends CharacterBody3D
class_name Drone

signal shutdown_complete
signal respawn(drone)

enum Icons {DOWN=0, UP=1, NO=2, QUESTION=3, SOUND=4, BATTERY=5, NOBATTERY=6}

# Drone movement statistics
var burden: float = 0.2 # How much carrying an item slows you.

var walk_speed: float = 5.0 # Base speed
var sprint_speed: float = 7.0 * 1 # Sprinting speed
var read_speed: float = 2.0 # How fast drone moves while reading task list.
var current_speed: float = walk_speed # Holds which speed value to use for movement calcs

var sprint_drain: float = 0.3 # How much more battery drains while sprinting
var base_velocity: Vector3 = Vector3(0,0,0)

@onready var icon_display: Sprite3D = get_node("Display/Icon")
@onready var id_display: Node3D = get_node("Display/ID")
@onready var display_container: Node3D = get_node("Display")
@onready var sprite: AnimatedSprite3D = get_node("BodyOld")
@onready var body: Node3D = get_node("Body")

@onready var sfx: AudioStreamPlayer = get_node("SFX")
@onready var shutdown: AudioStream = load("res:/sfx/shutdown3.ogg")
@onready var sfx_battery: AudioStream = load("res://sfx/battery.ogg")

@onready var battery = get_node("BatteryPower")

@onready var inventory = get_node("Inventory")

@onready var south_ray = get_node("SouthRaycast")
@onready var north_ray = get_node("NorthRaycast")

@onready var pickup_area = get_node("PickupArea")
@onready var interact_area = get_node("Body/InteractArea")

@onready var drop_location = get_node("ItemDrop")

@onready var beepboop_src = preload("res://objects/Beepboop.tscn")

var focus: Node

var nearby: Node # holds the nearest interactable object that the drone is facing

var look_target = Vector3(0,0,0)

var immobile: bool = false

func _ready():
	print("drone ready???")
	inventory.battery.track(battery)
	#gravity = 0
	set_colour()
	
func set_colour():
	$Body/Mesh/Body.mesh.surface_get_material(2).albedo_color = GLOBAL.color
	$Body/Mesh/Body/Head/Screen.mesh.surface_get_material(0).albedo_color = GLOBAL.color
	
	
func toggle_face():
	if icon_display.visible == true:
		show_id()
	else:
		show_icon()

func show_id():
	icon_display.visible = false
	id_display.visible = true
	
func show_icon(index: int = 0):
	icon_display.frame = index
	icon_display.visible = true
	id_display.visible = false
	$FaceTimer.start()

func toggle_display():
	display_container.visible = !display_container.visible
		
func get_nearby_objects():
	for body in interact_area.get_overlapping_bodies():
		if body is not Interactable: continue
		focus = body
		return
	focus = null
		
func handle_movement():
	var movement = Vector3(0,0,0)
	if Input.is_action_pressed("move_up"):
		movement.z = -1
	if Input.is_action_pressed("move_down"):
		movement.z = 1
	if Input.is_action_pressed("move_left"):
		movement.x = -1
	if Input.is_action_pressed("move_right"):
		movement.x = 1
	
	if movement == Vector3.ZERO:
		if $Body/AnimationPlayer.get_current_animation() not in ["Sit", "Snooze"]:
			$Body/AnimationPlayer.play("Pause")
			$Body/AnimationPlayer.queue("Sit")
			$Body/AnimationPlayer.queue("Snooze")
	else:
		var dir = position - movement
		body.look_at(dir)
		body.rotation_degrees = Vector3(0, snapped(body.rotation_degrees.y, 45), 0)
		if $Body/AnimationPlayer.get_current_animation() != "Walk":
			$Body/AnimationPlayer.clear_queue()
			$Body/AnimationPlayer.play("RESET")
			$Body/AnimationPlayer.queue("Walk")
	
	if Input.is_action_pressed("task_list"):
		$Body/AnimationPlayer.speed_scale = 0.5
		current_speed = read_speed
	elif Input.is_action_pressed("move_sprint") and movement != Vector3.ZERO:
		$Body/AnimationPlayer.speed_scale = 2
		$Body/Mesh/Dust.emitting = true
		current_speed = sprint_speed
	else:
		$Body/AnimationPlayer.speed_scale = 1
		$Body/Mesh/Dust.emitting = false
		current_speed = walk_speed

	if movement == Vector3.ZERO:
		velocity = lerp(velocity, Vector3.ZERO, 0.9)
	else:
		velocity = movement.normalized() * current_speed
	move_and_slide()
	
func handle_actions():
	if Input.is_action_just_pressed("interact"):
		interact()
		
	if Input.is_action_just_pressed("beep"):
		print("Beep!")
		
	if Input.is_action_just_pressed("task_list"):
		var tasks = $TaskFindArea.get_overlapping_bodies()
		var filtered_tasks = []
		for task in tasks:
			if task is Interactable and task.task != null:
				filtered_tasks.append(task)
		$TaskList.show_tasks(filtered_tasks)
	
	if $Body/AnimationPlayer.get_current_animation() in ["Walk", "Pause"] and focus != null:
		var before_look = $Body/Mesh/Body/Head.rotation_degrees
		$Body/Mesh/Body/Head.look_at(focus.global_position, Vector3.UP, true)
		var after_look = $Body/Mesh/Body/Head.rotation_degrees
		after_look.y = clampf(after_look.y, -50, 50)
		after_look.x = clampf(after_look.x, -10, 10)
		look_target = after_look
		$Body/Mesh/Body/Head.rotation_degrees = before_look
		$Body/Mesh/Body/Head.rotation_degrees = lerp($Body/Mesh/Body/Head.rotation_degrees, look_target, 0.2) 
	elif $Body/AnimationPlayer.get_current_animation() in ["Walk", "Pause"] and focus == null:
		look_target = Vector3(0,0,0)
		$Body/Mesh/Body/Head.rotation_degrees = lerp($Body/Mesh/Body/Head.rotation_degrees, look_target, 0.2)
		
	
	

func _process(delta):
	
	if position.y < -3:
		emit_signal("respawn")
		return

	handle_movement()
	get_nearby_objects()
	handle_actions()

	
func interact():
	if focus != null and focus is Interactable:
		focus.interact(null, self)
