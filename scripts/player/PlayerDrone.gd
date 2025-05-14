extends CharacterBody3D
class_name Drone

signal shutdown_complete
signal respawn(drone)

enum Icons {DOWN=0, UP=1, NO=2, QUESTION=3, SOUND=4, BATTERY=5, NOBATTERY=6}

# Drone movement statistics
var burden: float = 0.2 # How much carrying an item slows you.
var speed: float = 5.0 # Base speed
var sprint: float = 7.0 * 2 # Sprinting speed
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
	
func get_move_speed():
	if Input.is_action_pressed("move_sprint"):
		return sprint
	else:
		return speed
	
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
		if $Body/AnimationPlayer.get_current_animation() not in ["Sit", "Snooze"]:
			$Body/AnimationPlayer.play("RESET")
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
			
	if Input.is_action_pressed("move_sprint") and movement != Vector3.ZERO:
		$Body/AnimationPlayer.speed_scale = 2
		$Body/Mesh/Dust.emitting = true
	else:
		$Body/AnimationPlayer.speed_scale = 1
		$Body/Mesh/Dust.emitting = false

	velocity = movement.normalized() * get_move_speed()
	#velocity.y = -5
		
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
