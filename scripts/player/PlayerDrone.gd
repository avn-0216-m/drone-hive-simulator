extends CharacterBody3D
class_name Drone

signal shutdown_complete
signal respawn(drone)

enum Icons {DOWN=0, UP=1, NO=2, QUESTION=3, SOUND=4, BATTERY=5, NOBATTERY=6}

# Drone movement statistics
var burden: float = 0.2 # How much carrying an item slows you.
var speed: float = 5.0 # Base speed
var sprint: float = 7.0 # Sprinting speed
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

var nearby: Node # holds the nearest interactable object that the drone is facing

var id: String = "0000"
var headbob_offset: Vector2 = Vector2(2.4, 2.3) #y if head is dipped, else x.

var immobile: bool = false

var move_up = 1
var move_down = 2
var move_left = 4
var move_right = 8
var inventory_left = 16
var inventory_right = 32
var interact_btn = 64

func _ready():
	print("drone ready???")
	inventory.battery.track(battery)
	#gravity = 0
	$Body/Mesh/Body.mesh.surface_get_material(2).albedo_color = GLOBAL.color
	$Body/Mesh/Head/Screen.mesh.surface_get_material(0).albedo_color = GLOBAL.color
	
func set_colour():
	$Body/Mesh/Body.mesh.surface_get_material(2).albedo_color = GLOBAL.color
	$Body/Mesh/Head/Screen.mesh.surface_get_material(0).albedo_color = GLOBAL.color
	
	
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
	
func get_move_speed():
	if Input.is_action_pressed("move_sprint"):
		return sprint
	else:
		return speed
	
func get_inputs() -> int:
	
	if immobile:
		return 0
	
	var inputs = 0
	
	if Input.is_action_pressed("move_left"):
		inputs += move_left
		body.rotation_degrees.y = 270
	if Input.is_action_pressed("move_right"):
		inputs += move_right
		body.rotation_degrees.y = 90
	if Input.is_action_pressed("move_up"):
		inputs += move_up
		body.rotation_degrees.y = 180
	if Input.is_action_pressed("move_down"):
		body.rotation_degrees.y = 0
		inputs += move_down
		
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_right"):
		body.rotation_degrees.y = 45
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_right"):
		body.rotation_degrees.y = 135
	if Input.is_action_pressed("move_up") and Input.is_action_pressed("move_left"):
		body.rotation_degrees.y = 225
	if Input.is_action_pressed("move_down") and Input.is_action_pressed("move_left"):
		body.rotation_degrees.y = 315
		
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_left"):
		if not $Body/AnimationPlayer.is_playing():
			$Body/AnimationPlayer.play("Walk")
	else:
		$Body/AnimationPlayer.play("RESET")
		
	if Input.is_action_pressed("move_sprint"):
		$Body/AnimationPlayer.speed_scale = 2
		$Body/Mesh/Dust.emitting = true
	else:
		$Body/AnimationPlayer.speed_scale = 1
		$Body/Mesh/Dust.emitting = false
		
	
	
	if Input.is_action_just_pressed("inventory_left"):
		inventory.change_slot(-1)
	elif Input.is_action_just_pressed("inventory_right"):
		inventory.change_slot(1)
	if Input.is_action_just_pressed("interact"):
		interact()
	elif Input.is_action_just_pressed("inventory_cancel"):
		inventory.change_slot(0)
	
	if Input.is_action_just_pressed("beep"):
		
		GLOBAL.color = Color(randf(), randf(), randf())
		set_colour()
		
		return 1
		
		if has_node("Beepboop"):
			get_node("Beepboop").free()
		
		var beepboop_obj = beepboop_src.instantiate()
			
		add_child(beepboop_obj)
		beepboop_obj.position.z = 0.3
		show_icon(Icons.SOUND)
		inventory.inventory_timeout()
		


	
	
	return inputs
	
func get_nearbys() -> Node:
	var nearby_bodies = interact_area.get_overlapping_bodies()
	for body in nearby_bodies:
		if body is Interactable and body.type != body.Type.NONE:
			return body
	return null

func _process(delta):
	
	if position.y < -3:
		emit_signal("respawn")
		return

	
	var movement = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	movement = Vector3(movement.x, 0, movement.y)
	if movement == Vector3.ZERO:
		velocity = lerp(velocity, Vector3.ZERO, 0.9)
		$Body/AnimationPlayer.play("RESET")
	else:
		var dir = position - movement
		body.look_at(dir)
		body.rotation_degrees = Vector3(0, snapped(body.rotation_degrees.y, 45), 0)
		if $Body/AnimationPlayer.get_current_animation() != "Walk":
			$Body/AnimationPlayer.play("Walk")
			
	if Input.is_action_pressed("move_sprint") and movement != Vector3.ZERO:
		$Body/AnimationPlayer.speed_scale = 2
		$Body/Mesh/Dust.emitting = true
	else:
		$Body/AnimationPlayer.speed_scale = 1
		$Body/Mesh/Dust.emitting = false

	velocity = movement.normalized() * get_move_speed()
	velocity.y = -5
		
	move_and_slide()
	
	nearby = get_nearbys()

	
func interact():
	if nearby == null:
		if inventory.item_selected:
			var item = inventory.pop_item()
			if item.parent.has_method("to_local"):
				item.position = item.parent.to_local(drop_location.get_global_transform().origin)
			item.parent.add_child(item)
			item.emit_signal("dropped")
			show_icon(Icons.DOWN)
		else:
			# select inventory item
			inventory.select_item()
	elif nearby is Pickup:
		if inventory.current_slot_empty():
			var item = nearby.interact(self)
			inventory.set_item(item)
			show_icon(Icons.UP)
		else:
			UI.log("You're already holding something.")
			show_icon(Icons.NO)
	elif nearby is Interactable and not nearby is Pickup:
		# interact code here. nest additional code for interacting with objects
		if (nearby.type in [nearby.Type.BOTH, nearby.Type.ITEMS] and 
		inventory.item_selected):
			var inv_item = inventory.get_item()
			var result = inv_item.use_on(nearby)
			if result == inv_item.Result.FAIL:
				UI.log(
					"You cannot use " + 
					inv_item.interactable_name + 
					" on the " + 
					nearby.interactable_name + 
					"."
				)
				inventory.play_sfx(inventory.Sfx.LOW)
				show_icon(Icons.NO)
			elif result == inv_item.Result.CONSUMED:
				inventory.play_sfx(inventory.Sfx.HIGH)
				inventory.delete_item()
			elif result == inv_item.Result.WRONG_VARIANT:
				inventory.play_sfx(inventory.Sfx.LOW)
			else:
				inventory.play_sfx(inventory.Sfx.HIGH)
		elif (nearby.type == nearby.Type.ITEMS and !inventory.item_selected):
			UI.log(
				"You need to use an item on the " + 
				nearby.interactable_name + 
				"."
			)
			inventory.play_sfx(inventory.Sfx.LOW)
		elif (nearby.type in [nearby.Type.BOTH, nearby.Type.DIRECT]):
			nearby.interact(self)
		elif (nearby.type == nearby.Type.NONE):
			UI.log("You cannot use the " + nearby.interactable_name + ".")
			inventory.play_sfx(inventory.Sfx.LOW)
	else:
		inventory.play_sfx(inventory.Sfx.LOW)
