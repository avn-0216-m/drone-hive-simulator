extends Node3D
class_name Room

@export var unlock_floor: int = 0

@export_enum(
	"Unspecified", "Bedroom", "Kitchen", "Hallway", 
	"Bathroom", "Lounge"
	) var room_type: int
	
var potentials: Array = []
@onready var foundations = get_node("Foundations")

func get_potentials():
	return potentials


func setup_doors():
	for potential in potentials:
		if potential.is_door:
			$Foundations.set_cell_item(potential.cell, -1, potential.orientation)
		else:
			$Foundations.set_cell_item(potential.cell, 4, potential.orientation)

func _ready():
	# get all potentials
	for cell in $Foundations.get_used_cells_by_item(7):
		var potential = Potential.new()
		potential.room = self
		potential.orientation = $Foundations.get_cell_item_orientation(cell)
		potential.cell = cell
		potentials.append(potential)
		
