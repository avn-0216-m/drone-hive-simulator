extends Spatial

enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

onready var walls = get_node("Geometry/Walls")
onready var floors = get_node("Geometry/Floor")

# This is gonna be a real headache if I ever add multiple doors with the same orientation.
export var north: bool
export var south: bool
export var east: bool
export var west: bool

var doors = []

signal doorway_added(pos)

func get_potentials() -> Array:
	# Returns an array of Potential data.
	var potentials = []
	for cell in walls.get_used_cells():
		if walls.get_cell_item(cell.x, 0, cell.z) == 6: # 6 = potential
			var potential_data = Potential.new()
			potential_data.cell_local = cell
			potential_data.orientation = walls.get_cell_item_orientation(cell.x, 0, cell.z)
			potential_data.pos = walls.map_to_world(cell.x, 0, cell.z)
			potentials.append(potential_data)
	return potentials

func get_doors() -> Array:
	# deprecated
	var doors = []
	for door in walls.doors:
		# position here is given as a global.
		# position != cell
		# use a gridmap at 0,0,0 to convert global positions to gridmap cell co-ords
		
		var door_data = Door.new()
		
		door_data.pos = to_global(walls.map_to_world(door.cell.x, 0, door.cell.z))
		door_data.room = self
		door_data.orientation = door.orientation
		doors.append(door_data)
	return doors
