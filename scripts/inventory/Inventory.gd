extends Spatial

onready var drone = get_node("../Drone")
onready var slots = get_node("Slots")
onready var cursor = get_node("Cursor")
var distance_between_slots: float = 1.1
onready var total_slots: int = 0
var inventory_index: int = 0
var cursor_target: Vector3 = Vector3(0,0,0)
var highlighted_object = null
var selected_slot # Slot accessed via inventory index. Updated every time change_selected_slot is called

var timeout: float = 3.0 # How many seconds before the inventory autohides

var placeholder: ImageTexture # placeholder texture for pickups that do not have one

var primed_item = null # The item selected from the inventory to be dropped/used

# Variables for inventory slot oscilation
var wiggle: bool = true # If true, slots will oscilate.
var time: float = 0 # Increases every frame for use in sin()
var magnitude: float = 0.07 # How much up and down the slots wiggle

var primed: bool = false # If the inventory has an item prepared to drop or not.

var sfx = [
	preload("res://sfx/inventory/inventorychange.ogg"),
	preload("res://sfx/inventory/inventoryconfirm.ogg"),
	preload("res://sfx/inventory/inventoryselect.ogg")
	]

enum SFX {low = 0, mid = 1, high = 2}

func play_sfx(choice: int = 0):
	$SFX.stream = sfx[choice]
	$SFX.play()

func _process(delta):
	
	#if slots.get_child(inventory_index).item != null:
	#	slots.get_child(inventory_index).item.translation = Vector3(3,3,0)
	
	slots.translation = drone.translation + Vector3(0,2.4,0)
	
	if wiggle:
		for i in range(0, total_slots):
			slots.get_child(i).translation.y = sin(time + (i*2)) * magnitude
			time += 0.02
		if time > 360:
			time = 0
	
	match(primed):
		false:
			if slots.visible or highlighted_object:
				cursor.visible = true
			else:
				cursor.visible = false

			# Set cursor target
			if highlighted_object:
				cursor_target = highlighted_object.get_global_transform().origin + highlighted_object.cursor_offset
			else:
				cursor_target = slots.get_child(inventory_index).translation + slots.translation + Vector3(0,1,0)

			cursor.translation = lerp(cursor.translation, cursor_target, 0.2 if highlighted_object else 0.5)
		true:
			
			if highlighted_object:
				cursor_target = highlighted_object.get_global_transform().origin + highlighted_object.cursor_offset
			else:
				cursor_target = drone.item_drop.get_global_transform().origin

			cursor.translation = lerp(cursor.translation, cursor_target, 0.4)
			
			cursor.visible = true
			slots.visible = true
		
func _ready():
	
	placeholder = ImageTexture.new()
	var placeholder_image = Image.new()
	placeholder_image.load("res://sprites/nosprite.png")
	placeholder.create_from_image(placeholder_image, 0)
	
	selected_slot = slots.get_child(inventory_index)
	
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
	
	play_sfx(SFX.low)
	# deprime current slot if applicable
	if primed:
		primed_item = null
		primed = false
		slots.get_child(inventory_index).material_override.albedo_color = slots.get_child(inventory_index).original_color
		update_cursor()
	
	show_slots()
	if desired_index < 0 or desired_index > total_slots - 1:
		return
	inventory_index = desired_index
	selected_slot = slots.get_child(inventory_index)
	update_cursor()

func update_cursor():
	cursor.material_override.albedo_color = slots.get_child(inventory_index).material_override.albedo_color
	cursor.material_override.albedo_color.a = 1

func current_slot_empty() -> bool:
	return selected_slot.item == null

func add_slot():
	print("Unimplemented")
	return
	
func use_item_on(body):
	print("using item on a body from inventory")
	if !body.interactable: return
	if body.get_class() in primed_item.interactions.keys():
		$SFXConfirm.play(0)
		if primed_item.interactions[body.get_class()].call_func(body):
			destroy_item()
	else:
		$SFXChange.play(0)


func destroy_item():
	primed_item = null
	primed = false
	selected_slot.item = null
	
	# delete icon image
	selected_slot.icon.texture = null
	selected_slot.icon.material_override.albedo_texture = null
	
	# undarken inventory slot and cursor
	selected_slot.material_override.albedo_color = selected_slot.original_color
	update_cursor()
	
	show_slots()
	
func drop_item():
	
	
	print("lookhere")
	print(primed_item.get_parent().to_local(drone.item_drop.get_global_transform().origin))
	print(drone.item_drop.get_global_transform().origin)
	
	$SFXConfirm.play(0)
	primed_item.translation = primed_item.get_parent().to_local(drone.item_drop.get_global_transform().origin)
	primed_item.velocity.y = 0
	primed_item.skip_process = false
	destroy_item()
	
func pop_item() -> PackedScene:
	return PackedScene.new()
	
func prime_item():
	print("priming item from inventory!")
	
	if selected_slot != null and selected_slot.item != null:
		$SFXSelect.play(0)
		print("item primed!")
		primed = true
		primed_item = selected_slot.item
		selected_slot.material_override.albedo_color = selected_slot.original_color
		update_cursor()
		print(primed_item)
	else:
		$SFXChange.play(0)
		print("no item selected!")
		primed = false

func inventory_timeout():
	slots.visible = false

func set_item(object: PackedScene) -> bool:
	selected_slot.item = object
	selected_slot.icon.visible = true
	return true
