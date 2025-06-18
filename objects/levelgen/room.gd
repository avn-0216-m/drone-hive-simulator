extends Node3D
class_name Room

@export var unlock_floor: int = 0

@export_enum(
	"Unspecified", "Bedroom", "Kitchen", "Hallway", 
	"Bathroom", "Lounge"
	) var room_type: int
	
@export var potentials: Array = []
@onready var foundations: GridMap = get_node("Foundations")
@onready var decor: GridMap = get_node("Decor")
@onready var door_src = load("res://objects/door/scifidoor.tscn")

func get_floor_cells_global_pos(depth: int = 0, exclude: Array = []) -> Array:
	var floor_cells_global: Array = []
	for cell in foundations.get_used_cells_by_item(2):
		floor_cells_global.append(to_global(cell * 2) + Vector3(1, 1, 1))
		if depth > 0:
			for pot in potentials:
				if pot.connection != null and pot.connection.room not in exclude:
					floor_cells_global += pot.connection.room.get_floor_cells_global_pos(depth - 1, exclude + [self])
	return floor_cells_global

func get_potentials():
	return potentials

func setup_doors():
	for potential in potentials:
		if potential.is_door:
			$Foundations.set_cell_item(potential.cell, -1, potential.orientation)
			var door_obj = door_src.instantiate()
			add_child(door_obj)
			door_obj.position = potential.cell * 2
			door_obj.position += Vector3(1,1,1)
			match potential.orientation:
				0: door_obj.rotation_degrees.y = 0 # West
				10: door_obj.rotation_degrees.y = 180 # East
				16: door_obj.rotation_degrees.y = 90 # South
				22: door_obj.rotation_degrees.y = 270 # North
		else:
			$Foundations.set_cell_item(potential.cell, 4, potential.orientation)



func _ready():
	foundations.set_collision_layer_value(2, true)
	
	# get all potentials
	for cell in $Foundations.get_used_cells_by_item(7):
		var potential = Potential.new()
		potential.room = self
		potential.orientation = $Foundations.get_cell_item_orientation(cell)
		potential.cell = cell
		potentials.append(potential)
