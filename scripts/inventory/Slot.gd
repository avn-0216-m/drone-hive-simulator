extends Sprite3D

var color_dampening: Color = Color(0.3,0.3,0.3,0)

var item: Node = null
onready var icon = get_node("Icon")
onready var color: Color = material_override.albedo_color
onready var selected_color: Color = material_override.albedo_color - color_dampening 
