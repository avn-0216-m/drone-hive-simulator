extends Node3D
class_name Room

@export_enum(
	"Unspecified", "Bedroom", "Kitchen", "Hallway", 
	"Bathroom", "Lounge"
	) var room_type: int

func _ready():
	# get all potentials
	for node in $Foundations.get_used_cells_by_item(7):
		
