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

func compare(room: Node, cell: Vector3):
	# Compares if space is already in use by other rooms via placeholder tiles
	# Returns true if not, false if it is.
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
