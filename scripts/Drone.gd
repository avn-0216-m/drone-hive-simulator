extends Spatial

onready var icon_display: Sprite3D = get_node("Display/Icon")
onready var id_display: Spatial = get_node("Display/ID")
onready var display_container: Spatial = get_node("Display")
onready var sprite: AnimatedSprite3D = get_node("Body")
var id: int = 0000
var headbob_offset: Vector2 = Vector2(2.0, 1.9) #y if head is dipped, else x.

func _ready():
	set_id(5890)
	
func set_id(new_id: int):
	if id > 9999 or id < 0:
		return
	id = new_id
	var id_string: String = str(id)
	id_display.get_node("ID1").frame = int(id_string.left(1))
	id_display.get_node("ID2").frame = int(id_string.left(2))
	id_display.get_node("ID3").frame = int(id_string.left(3))
	id_display.get_node("ID4").frame = int(id_string.left(4))
	
func toggle_face():
	if icon_display.visible:
		icon_display.visible = false
		id_display.visible = true
	else:
		icon_display.visible = true
		id_display.visible = false
		
func _process(delta):
	if sprite.frame % 2 != 0:
		display_container.translation.y = headbob_offset.y
	else:
		display_container.translation.y = headbob_offset.x
