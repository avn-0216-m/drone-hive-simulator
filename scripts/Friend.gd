extends Interactable
class_name Friend

onready var heart = get_node("Heart")
onready var lena = get_node("Lena")

func get_class() -> String:
	return "Friend"

func _ready():
	cursor_offset = Vector3(0,3,0)
