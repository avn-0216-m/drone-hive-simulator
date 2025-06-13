extends Node3D

@onready var parent: Drone = get_parent()
@onready var slots = get_node("Slots")
@onready var cursor = get_node("Cursor")
@onready var battery = get_node("Slots/Battery")
@onready var sfx = get_node("SFX")

@export var slot_count: int = 3
@export var slot_spacing: float = 1.1
@export var slot_dimming: float = 0.1

var current_slot_index: int = 0
var current_slot: Slot = null # Slot accessed via inventory index. Updated every time change_selected_slot is called
var item_selected: bool = false # If an item has been selected from the inventory.
var selected_item: Node
var cursor_target: Vector3 = Vector3.ZERO

signal item_dropped

var slot_colors: Array = [
	Color("d70270"),
	Color("734f96"),
	Color("0038a8"),
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0)
]

enum Sfx {LOW = 0, MID = 1, HIGH = 2}
var sfx_files = [
	preload("res://objects/inventory/inventorylow.ogg"),
	preload("res://objects/inventory/inventorymid.ogg"),
	preload("res://objects/inventory/inventoryhigh.ogg")
	]

func _ready():
	# set initial slot
	current_slot = slots.get_child(current_slot_index)
	
	# color slots
	for i in range(0, slots.get_child_count()):
		slots.get_child(i).set_base_color(slot_colors[i])
	
	slots.visible = false

func _process(delta):
	if Input.is_action_just_pressed("inventory_left"):
		change_slot(-1)
	if Input.is_action_just_pressed("inventory_right"):
		change_slot(1)

	set_cursor_position()
	
func set_cursor_position():
	if owner.focus != null:
		cursor.visible = true
		cursor_target = owner.to_local(owner.focus.global_position) + Vector3(0,owner.focus.cursor_offset,0)
	elif owner.focus == null and current_slot != null and current_slot.selected == false:
		cursor_target = current_slot.position + Vector3(0,6.5,0)
		cursor.visible = slots.visible
	elif owner.focus == null and current_slot.selected:
		cursor_target = owner.to_local(owner.drop_point.global_position)
		
	cursor.modulate = current_slot.sprite.modulate
	
	if slots.visible:
		cursor.position = lerp(cursor.position, cursor_target, 0.216)
	else:
		cursor.position = cursor_target
		
func play_sfx(choice: int = 0):
	sfx.stream = sfx_files[choice]
	sfx.play()
	
func pick_up_item(item: Interactable):
	show_slots()
	if current_slot.item != null:
		play_sfx(Sfx.LOW)
		UI.log("You're already holding something.")
		return
	item.get_parent().remove_child(item)
	current_slot.set_item(item)
	item.process_mode = Node.PROCESS_MODE_DISABLED
	play_sfx(Sfx.HIGH)
	
func get_item(slot: int):
	pass
	
func get_selected_item():
	if current_slot.selected == false:
		return null
	else:
		return current_slot.item
	
func hop():
	cursor.position += Vector3(0,1,0)

func change_slot(offset: int):
	show_slots()
	current_slot.deselect()
	if current_slot_index + offset < 0 or current_slot_index + offset > slot_count - 1:
		play_sfx(Sfx.LOW)
	else:
		current_slot_index += offset
		current_slot = slots.get_child(current_slot_index)
		play_sfx(Sfx.MID)

func select_item():
	show_slots()
	hop()
	if current_slot.item == null:
		play_sfx(Sfx.LOW)
	elif current_slot.item != null and current_slot.selected == false:
		play_sfx(Sfx.MID)
		current_slot.select()
	elif current_slot.item != null and current_slot.selected:
		play_sfx(Sfx.HIGH)
		var item = current_slot.pop_item()
		owner.get_parent().get_node("Objects").add_child(item)
		item.position = owner.drop_point.global_position

func consume_item():
	play_sfx(Sfx.HIGH)
	current_slot.pop_item()

func show_slots():
	slots.visible = true
	$VisibilityTimeout.start()
	
func timeout():
	slots.visible = false
