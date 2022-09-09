extends KinematicGravity
class_name Drone

signal shutdown_complete
signal respawn(drone)

# Drone movement statistics
var burden: float = 0.2 # How much carrying an item slows you.
var speed: float = 5.0 # Base speed
var sprint: float = 2 # How much faster sprinting makes you
var sprint_drain: float = 0.3 # How much more battery drains while sprinting


onready var icon_display: Sprite3D = get_node("Display/Icon")
onready var id_display: Spatial = get_node("Display/ID")
onready var display_container: Spatial = get_node("Display")
onready var sprite: AnimatedSprite3D = get_node("Body")

onready var sfx: AudioStreamPlayer = get_node("SFX")
onready var shutdown: AudioStream = load("res:/sfx/shutdown3.ogg")
onready var sfx_battery: AudioStream = load("res://sfx/battery.ogg")

onready var battery = get_node("BatteryPower")

onready var inventory = get_node("Inventory")

onready var south_ray = get_node("SouthRaycast")
onready var north_ray = get_node("NorthRaycast")

onready var pickup_area = get_node("PickupArea")
onready var interact_area = get_node("InteractArea")

onready var drop_location = get_node("ItemDrop")

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
var interact = 64

func _ready():
	$FaceTimer.connect("timeout", self, "show_id")
	set_id("0546")
	battery.connect("battery_charge_changed", inventory.battery, "on_battery_change")
	inventory.battery.maximum_charge = battery.maximum_charge
	
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
	
	if immobile:
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
	
	if Input.is_action_just_pressed("inventory_left"):
		inventory.change_slot(-1)
	elif Input.is_action_just_pressed("inventory_right"):
		inventory.change_slot(1)
	if Input.is_action_just_pressed("interact"):
		interact()
	elif Input.is_action_just_pressed("inventory_cancel"):
		inventory.change_slot(0)
	return inputs
	
func get_nearbys() -> Node:
	var nearby_bodies = interact_area.get_overlapping_bodies()
	for body in nearby_bodies:
		if body is Interactable and body.type != body.Type.NONE:
			return body
	return null

func _process(delta):
	
	if translation.y < -3:
		emit_signal("respawn")
		return
	
	if immobile:
		sprite.animation = "forward"
		sprite.playing = false
		sprite.frame = 0
		#display_container.translation.y = headbob_offset.y
		display_container.visible = true
		return

	
	velocity = Vector3(0,0,0)
	
	# Get inputs, set velocity
	var inputs = get_inputs()
	
	if inputs & move_right:
		velocity.x = 1 * speed
		sprite.flip_h = false
		display_container.translation = Vector3(0.05,2.4,0.15)
		interact_area.rotation_degrees.y = 0
		drop_location.translation.x = 3
	if inputs & move_left:
		velocity.x = -1 * speed
		sprite.flip_h = true
		display_container.translation = Vector3(-0.5,2.4,0.15)
		interact_area.rotation_degrees.y = 180
		drop_location.translation.x = -3
	if inputs & move_down:
		velocity.z = 1 * speed
		interact_area.rotation_degrees.y = 270
	if inputs & move_up:
		velocity.z = -1 * speed
		interact_area.rotation_degrees.y = 90

	# Check if drone should keep walking.
	sprite.playing = !(not inputs and (sprite.frame == 0 or sprite.frame == 2))
	
	nearby = get_nearbys()

	# Calculate headbob
	if sprite.frame % 2 != 0:
		display_container.translation.y = headbob_offset.y
	else:
		display_container.translation.y = headbob_offset.x
		
	#if velocity.z < 0:
	#	sprite.animation = "backward"
	#else:
	#	sprite.animation = "forward"
		
	#if sprite.animation == "backward":
	#	display_container.visible = false
	#else:
	#	display_container.visible = true

	
func interact():
	if nearby == null:
		if inventory.item_selected:
			var item = inventory.pop_item()
			if item.parent.has_method("to_local"):
				item.translation = item.parent.to_local(drop_location.get_global_transform().origin)
			item.parent.add_child(item)
			item.emit_signal("dropped")
		else:
			# select inventory item
			inventory.select_item()
	elif nearby is Pickup:
		if inventory.current_slot_empty():
			var item = nearby.interact(self)
			inventory.set_item(item)
		else:
			UI.log("You're already holding something.")
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
	
		
func recharge(amount: int = 100):
	sfx.stream = sfx_battery
	sfx.play()
	$BatteryParticles.one_shot = false
	$BatteryParticles.emitting = true
	$BatteryParticles.one_shot = true
	show_icon()
	$FaceTimer.start()	


func frame_changed():
	match(sprite.frame):
		1:
			$SFXs/Sprint.play()
		3:
			$SFXs/Sprint2.play()
		
