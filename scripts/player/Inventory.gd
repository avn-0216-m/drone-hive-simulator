extends Node3D

@onready var parent: Drone = get_parent()
@onready var slots = get_node("Slots")
@onready var cursor = get_node("Cursor")
@onready var battery = get_node("Slots/Battery")
@onready var sfx = get_node("SFX")

@export var slot_count: int = 3
@export var slot_spacing: float = 1.1
@export var slot_dimming: float = 0.1

var cursor_target: Vector3 = Vector3(0,0,0)
var slot_index: int = 0
var current_slot = null # Slot accessed via inventory index. Updated every time change_selected_slot is called
var item_selected: bool = false # If an item has been selected from the inventory.
var selected_item: Node

var slot_colours: Array = [
	Color(0,0,0),
	Color(0,0,0),
	Color(0,0,0),
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

func _process(delta):
	if Input.is_action_just_pressed("inventory_left"):
		change_slot(-1)
	if Input.is_action_just_pressed("inventory_right"):
		change_slot(1)
		
	set_cursor_position()
	
func set_cursor_position():
	if owner.focus != null:
		cursor.position = owner.to_local(owner.focus.global_position) + Vector3(0,3,0)
		cursor.visible = true
	else:
		cursor.visible = false
	return
		
func play_sfx(choice: int = 0):
	sfx.stream = sfx_files[choice]
	sfx.play()
	
func pickup_item(item: Interactable):
	pass
	
func drop_item(item: Interactable):
	pass
	
func get_item(slot: int):
	pass

func clear_slot(slot: int):
	pass

func change_slot(offset: int):
	popup()
	if slot_index + offset < 0 or slot_index + offset > slot_count:
		play_sfx(Sfx.LOW)
	else:
		slot_index += offset
		current_slot = slots.get_child(slot_index)
		play_sfx(Sfx.MID)

func get_selected_item():
	return null

func popup():
	slots.visible = true
	$VisibilityTimeout.start()
	
func timeout():
	slots.visible = false
