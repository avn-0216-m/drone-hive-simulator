extends GridMap

export var padding = 3

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

func add(room: Node):
	var pad_these = []
	var pad_these_too = []
	var tiles = room.walls.get_used_cells()
	for tile in tiles:
		var local_pos = room.walls.map_to_world(tile.x, tile.y, tile.z)
		var world_pos = room.walls.to_global(local_pos)
		var ph_pos = world_to_map(world_pos)
		set_cell_item(ph_pos.x, ph_pos.y, ph_pos.z, 0)
		pad_these.append(Vector3(ph_pos.x, ph_pos.y, ph_pos.z))
		
	for i in range(0, padding):
		pad_these.append_array(pad_these_too)
		for p in pad_these:
			for a in adjacent:
				set_cell_item(p.x + a.x, p.y + a.y, p.z + a.z, 0)
				pad_these_too.append(Vector3(p.x + a.x, p.y + a.y, p.z + a.z))