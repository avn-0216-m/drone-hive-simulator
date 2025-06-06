extends GridMap

enum Geo { BOX,CORNER,POST,WALL,DOUBLE,CURVE,POTENTIAL}

@export var potential_base = 10.0 # chance for a Potential tile to become a door
@export var potential_decay = 4.5 # loss of chance per each successful door spawn
var potential = potential_base

signal doorway_added(pos)

var door_src: PackedScene = preload("res://objects/Door.tscn")
var door_obj = null
var doors = []

var potentials = []

func get_wall_cells():
	# Does not return placeholder cells.
	var walls = []
	for cell in get_used_cells():
		if get_cell_item(Vector3i(cell.x, 0, cell.z)) != 6:
			walls.append(cell)
	return walls

func add_doorways_old() -> Array:
	
	var cells = get_used_cells()
	cells.shuffle() # randomizes doorway placement.
	
	for cell in cells:
		if get_cell_item(Vector3i(cell.x, cell.y, cell.z)) == Geo.POTENTIAL:
			door_obj = door_src.instantiate()
			door_obj.position = map_to_local(Vector3i(cell.x, cell.y, cell.z))
			var door_data = Door.new()
			door_data.cell = Vector3(cell.x, cell.y, cell.z)
			door_data.orientation = get_cell_item_orientation(Vector3i(cell.x, cell.y, cell.z))
			# gotta grab the orientation now because it's not preserved if you delete
			# the cell.
			doors.append(door_data)
			match door_data.orientation:
				0: # eastern
					door_obj.rotation_degrees.y = 0
				10: # western
					door_obj.rotation_degrees.y = 180
				16: # southern
					door_obj.rotation_degrees.y = 90
				22: # northern
					door_obj.rotation_degrees.y = 270
			add_child(door_obj)
		# Then, replace potential with empty or a wall.
			set_cell_item(Vector3(cell.x, cell.y, cell.z), 
				-1 if door_obj != null else Geo.WALL, 
				get_cell_item_orientation(Vector3i(cell.x, cell.y, cell.z)))
			door_obj = null
	return doors
