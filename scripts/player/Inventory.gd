extends Spatial

onready var parent: Drone = get_parent()
onready var slots = get_node("Slots")
onready var cursor = get_node("Cursor")
var distance_between_slots: float = 1.1

var cursor_target: Vector3 = Vector3(0,0,0)
var current_index: int = 0
var current_slot = null # Slot accessed via inventory index. Updated every time change_selected_slot is called
var item_selected = false # If an item has been selected from the inventory.

var timeout: float = 3.0 # How many seconds before the inventory autohides

var slot_colours: Array = [
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0)
]

var sfx = [
	preload("res://sfx/inventory/inventorylow.ogg"),
	preload("res://sfx/inventory/inventorymid.ogg"),
	preload("res://sfx/inventory/inventoryhigh.ogg")
	]

enum Sfx {LOW = 0, MID = 1, HIGH = 2}

func play_sfx(choice: int = 0):
	$SFX.stream = sfx[choice]
	$SFX.play()
	
func jump():
	cursor.translation.y += 0.5
	
func set_slot_color(selected: bool):
	show_slots()
	current_slot.select(selected)
	update_cursor()

func _physics_process(delta):
	
	if is_instance_valid(parent.nearby) and parent.nearby.get_global_transform().origin != Vector3(0,0,0):
		cursor_target = to_local(parent.nearby.get_global_transform().origin + parent.nearby.cursor_offset)
	elif item_selected:
		cursor_target = to_local(parent.drop_location.get_global_transform().origin)
	else:
		cursor_target = to_local(current_slot.get_global_transform().origin + Vector3(0,1,0))
	
	if visible:	
		cursor.translation = lerp(cursor.translation, cursor_target, 0.3)
	else:
		cursor.translation = cursor_target
		
	cursor.visible = slots.visible or parent.nearby or item_selected
		
func _ready():
	
	current_slot = slots.get_child(0)
	
	$VisibilityTimer.connect("timeout",self,"inventory_timeout")
	$VisibilityTimer.start()
	
	for slot in slots.get_children():
		slot.connect("duplicate_item", self, "duplicate_item")
	
	# start slot wiggle animation
	for i in range (0, slots.get_child_count()):
		slots.get_child(i).get_node("AnimationPlayer").play("wiggle")
		slots.get_child(i).get_node("AnimationPlayer").advance(1 * i)

	var total_slots = len(slots.get_children())
	# Calculate how far back slots should start being placed so the drone is the midpoint.
	var slot_translation = distance_between_slots * - (total_slots/2)
	
	# If even amount of slots, offset by half the distance so the middle
	# slot is still directly above the parent.
	if total_slots % 2 == 0:
		slot_translation += (distance_between_slots/2)
	for slot in slots.get_children():
		slot.translation = Vector3(slot_translation, 0, 0)
		slot_translation += distance_between_slots
	update_cursor()
	
func show_slots():
	slots.visible = true
	$VisibilityTimer.start(timeout)
	
func change_slot(desired_index):
	
	# reset any item selection
	set_slot_color(false)
	item_selected = false
	
	play_sfx(Sfx.LOW)
	
	show_slots()
	if (current_index + desired_index) < 0 or (current_index + desired_index) > slots.get_child_count() - 1:
		return
	current_index += desired_index
	current_slot = slots.get_child(current_index)
	update_cursor()

func update_cursor():
	cursor.material_override.albedo_color = current_slot.get_color()
	cursor.material_override.albedo_color.a = 1

func current_slot_empty() -> bool:
	return current_slot.item == null

func add_slot():
	print("Unimplemented")
	return
	
func pop_item() -> Node:
	show_slots()
	play_sfx(Sfx.HIGH)
	item_selected = false
	return current_slot.pop_item()
	
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

func set_item(object: Node) -> bool:
	show_slots()
	if current_slot_empty():
		current_slot.set_item(object)
		play_sfx(Sfx.MID)
		return true
	else:
		UI.log("The item vanished into thin air.")
		play_sfx(Sfx.LOW)
		return false

func get_item() -> Node:
	return current_slot.item
	
func delete_item() -> void:
	current_slot.pop_item()
	item_selected = false
	set_slot_color(false)

func duplicate_item(item: Node):
	var next_available_slot = null
	for slot in slots.get_children():
		if slot.item == null:
			next_available_slot = slot
			break
	if next_available_slot == null:
		UI.log("Your inventory is overflowing.")
	else:
		UI.log("Your inventory feels heavier.")
		var dupe = item.duplicate(8)
		dupe.parent = item.parent
		next_available_slot.set_item(dupe)
