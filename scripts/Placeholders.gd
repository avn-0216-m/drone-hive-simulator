extends GridMap

export var padding = 3
var strip_these: Array = []

var adjacent: Array = [ # Transforms for all 8 adjacent tiles
		Vector3(-1,0,-1), # Top left
		Vector3(0,0,-1),  # Top mid
		Vector3(1,0,-1), # Top right
		Vector3(-1,0,0), # Mid left
		Vector3(1,0,0), # Mid right
		Vector3(-1,0,1), # Bottom left
		Vector3(0,0,1), # Bottom mid
		Vector3(1,0,1) # Bottom right
	]

func test(room: Node):
	# Tests if space is already in use by other rooms via placeholder tiles
	# Returns true if not, false if it is.
	
	print("Testing: " + room.name + " at: " + str(room.translation))
	
	for cell in room.walls.get_used_cells():
		var converted = world_to_map(map_to_world(cell.x, 0, cell.z) + room.translation)
		if get_cell_item(converted.x, 0, converted.z) != -1:
				print("!!! Bad room found. !!!")
				return false
	return true

func add(room: Node):
	var tiles = room.walls.get_wall_cells() # does not get placeholders, to prevent accidental self collisions.
	for tile in tiles:
		var local_pos = room.walls.map_to_world(tile.x, tile.y, tile.z)
		var world_pos = room.walls.to_global(local_pos)
		var ph_pos = world_to_map(world_pos)
		set_cell_item(ph_pos.x, ph_pos.y, ph_pos.z, 0)
		
func remove(cell: Vector3):
	return
