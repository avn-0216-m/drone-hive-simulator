extends Node3D
class_name Slot

var item: Node = null
var original_scale = Vector3(1,1,1)
var selected: bool = false
var base_color: Color
@onready var sprite: Sprite3D = get_node("Sprite")

	
func reset_rotation():
	sprite.rotation_degrees = Vector3.ZERO

func set_base_color(color: Color):
	sprite.modulate = color 
	base_color = color

func set_item(item: Node):
	add_child(item)
	item.process_mode = Node.PROCESS_MODE_DISABLED
	item.position = Vector3.ZERO
	original_scale = item.scale
	if item.pickup_scale != 0.0:
		item.scale = Vector3(item.pickup_scale, item.pickup_scale, item.pickup_scale)
	else:
		item.scale = Vector3(0.9,0.9,0.9)
	self.item = item
	
func select():
	selected = true
	sprite.modulate = base_color.darkened(0.5)
	
func deselect():
	selected = false
	sprite.modulate = base_color

func pop_item() -> Node:
	var drop = item
	remove_child(drop)
	drop.process_mode = Node.PROCESS_MODE_ALWAYS
	drop.scale = original_scale
	self.item = null
	deselect()
	reset_rotation()
	var spin_tween: Tween = get_tree().create_tween()
	spin_tween.tween_property(sprite, "rotation_degrees:x", 180, 0.4).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	spin_tween.finished.connect(reset_rotation)
	return drop
