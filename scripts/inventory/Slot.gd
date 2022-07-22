extends Sprite3D

var color_dampening: Color = Color(0.3,0.3,0.3,0)
var goopy_color: Color = Color(1,0.5,1,1) # bawk bawk :3c

var placeholder_texture: Texture = load("res://sprites/avn logo pixel.png")

var item: Node = null
onready var icon = get_node("Icon")

var selected: bool

signal anna_duplicated

# Unmodified base color so color can be reset after modifications
onready var original_color: Color = material_override.albedo_color

# Color for inventory slot which has been selected.
onready var selection_color: Color = material_override.albedo_color - color_dampening 
# Color for unselected inventory slot.
onready var unselected_color: Color = original_color

func get_color():
	if selected:
		return selection_color
	return unselected_color

func set_icon(texture: Texture):
	if texture == null:
		icon.material_override.albedo_texture = placeholder_texture
		icon.texture = placeholder_texture
	else:
		icon.material_override.albedo_texture = texture
		icon.texture = texture

func _ready():
	$Tween.connect("tween_completed", self, "tween_complete")
	connect("anna_duplicated",get_parent().get_parent(),"duplicate_anna")

func set_item(item: Node):
	self.item = item
	icon.visible = true
	
	set_icon(item.icon)
	
	if item is Anna:
		$Tween.interpolate_method(self, "set_color", original_color, goopy_color, 10, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		$Tween.start()

func tween_complete(obj, key):
	UI.log("You feel your inventory getting heavier.")
	emit_signal("anna_duplicated")
	# Reset color back to base
	set_color(original_color)

func select(selected: bool):
	self.selected = selected
	if selected:
		material_override.albedo_color = selection_color
	else:
		material_override.albedo_color = unselected_color

func set_color(color: Color):
	unselected_color = color
	selection_color = color - color_dampening
	material_override.albedo_color = selection_color if selected else unselected_color
	get_parent().get_parent().update_cursor()
