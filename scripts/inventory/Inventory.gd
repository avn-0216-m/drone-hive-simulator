extends Spatial

onready var drone = get_node("../Drone")
onready var slots = get_node("Slots")
onready var cursor = get_node("Cursor")
var distance_between_slots: float = 1.1
onready var total_slots: int = 0
var inventory_index: int = 0
var cursor_target: Vector3 = Vector3(0,0,0)
var highlighted_object = null
var current_slot = null # Slot accessed via inventory index. Updated every time change_selected_slot is called
var item_selected = false # If an item has been selected from the inventory.

var timeout: float = 3.0 # How many seconds before the inventory autohides

var placeholder: ImageTexture # placeholder texture for pickups that do not have one

# Variables for inventory slot oscilation
var wiggle: bool = true # If true, slots will oscilate.
var time: float = 0 # Increases every frame for use in sin()
var magnitude: float = 0.07 # How much up and down the slots wiggle

var primed: bool = false # If the inventory has an item prepared to drop or not.

var sfx = [
	preload("res://sfx/inventory/inventorylow.ogg"),
	preload("res://sfx/inventory/inventorymid.ogg"),
	preload("res://sfx/inventory/inventoryhigh.ogg")
	]

enum Sfx {LOW = 0, MID = 1, HIGH = 2}

func play_sfx(choice: int = 0):
	$SFX.stream = sfx[choice]
	$SFX.play()
	
func set_slot_color(selected: bool):
	show_slots()
	if selected:
		current_slot.material_override.albedo_color = current_slot.selected_color
	else:
		current_slot.material_override.albedo_color = current_slot.color
	update_cursor()

func _physics_process(delta):
	
	#if slots.get_child(inventory_index).item != null:
	#	slots.get_child(inventory_index).item.translation = Vector3(3,3,0)
	
	slots.translation = drone.translation + Vector3(0,2.4,0)
	
	if wiggle:
		for i in range(0, total_slots):
			slots.get_child(i).translation.y = sin(time + (i*2)) * magnitude
			time += 0.02
		if time > 360:
			time = 0
	
	cursor.visible = visible or drone.nearby_interactable or item_selected
	
	cursor_target = Vector3(0,0,0)
	
	if drone.nearby_interactable and drone.nearby_interactable.get_global_transform().origin != Vector3(0,0,0):
		cursor_target = drone.nearby_interactable.get_global_transform().origin
	else:
		cursor_target = current_slot.get_global_transform().origin + Vector3(0,1,0)
	
	if visible:	
		cursor.translation = lerp(cursor.translation, cursor_target, 0.3)
	else:
		cursor.translation = cursor_target
		
func _ready():
	
	placeholder = ImageTexture.new()
	var placeholder_image = Image.new()
	placeholder_image.load("res://sprites/nosprite.png")
	placeholder.create_from_image(placeholder_image, 0)
	
	current_slot = slots.get_child(inventory_index)
	
	$VisibilityTimer.connect("timeout",self,"inventory_timeout")
	$VisibilityTimer.start()
	
	total_slots = len(slots.get_children())
	# Calculate how far back slots should start being placed so the drone is the midpoint.
	var slot_translation = distance_between_slots * - (total_slots/2)
	
	# If even amount of slots, offset by half the distance so the middle
	# slot is still directly above the drone.
	if total_slots % 2 == 0:
		slot_translation += (distance_between_slots/2)
	for slot in slots.get_children():
		slot.translation = Vector3(slot_translation, 0, 0)
		slot_translation += distance_between_slots
	update_cursor()
	
func show_slots():
	slots.visible = true
	$VisibilityTimer.start(timeout)
	
func change_selected_slot(desired_index):
	
	# reset any item selection
	set_slot_color(false)
	item_selected = false
	
	play_sfx(Sfx.LOW)
	
	show_slots()
	if desired_index < 0 or desired_index > total_slots - 1:
		return
	inventory_index = desired_index
	current_slot = slots.get_child(inventory_index)
	update_cursor()

func update_cursor():
	cursor.material_override.albedo_color = current_slot.material_override.albedo_color
	cursor.material_override.albedo_color.a = 1

func current_slot_empty() -> bool:
	print("Current slot empty: " + str(current_slot.item == null))
	return current_slot.item == null

func add_slot():
	print("Unimplemented")
	return
	
func pop_item() -> Node:
	show_slots()
	var item = current_slot.item
	current_slot.item = null
	current_slot.icon.visible = false
	set_slot_color(false)
	
	play_sfx(Sfx.HIGH)
	item_selected = false
	return item
	
func select_item():
	show_slots()
	if current_slot_empty():
		play_sfx(Sfx.LOW)
	else:
		play_sfx(Sfx.MID)
		item_selected = true
		set_slot_color(true)

func inventory_timeout():
	slots.visible = false

func set_item(object: Node):
	show_slots()
	current_slot.item = object
	current_slot.icon.visible = true
	play_sfx(Sfx.MID)
