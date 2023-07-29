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
				if i == padding and get_cell_item(p.x + a.x, 0, p.z + a.z) == -1:
					# done to remove the outermost padding layer for easier hallways
					strip_these.append(Vector3(p.x + a.x, 0, p.z + a.z))
				set_cell_item(p.x + a.x, 0, p.z + a.z, 0)
				pad_these_too.append(Vector3(p.x + a.x, 0, p.z + a.z))
				
func clear_doorways(doors):
	for door in doors:
		var cell = door["pos"]
		cell = world_to_map(cell)
		for i in range(0, padding + 2):
			set_cell_item(cell.x, 0, cell.z, -1)
			match door["orientation"]:
				0: # eastern
					cell.x -= 1
				10: # western
					cell.x += 1
				16: # southern
					cell.z += 1
				22: # northern
					cell.z -= 1

func strip():
	for tile in strip_these:
		set_cell_item(tile.x, tile.y, tile.z, -1)
