extends GridMap

var adjacent_transforms: Array = [ # Transforms for all 8 adjacent tiles
		Vector3(-1,0,-1), # Top left
		Vector3(0,0,-1),  # Top mid
		Vector3(1,0,-1), # Top right
		Vector3(-1,0,0), # Mid left
		Vector3(1,0,0), # Mid right
		Vector3(-1,0,1), # Bottom left
		Vector3(0,0,1), # Bottom mid
		Vector3(1,0,1) # Bottom right
	]

const WALL_INDEX = 1
var original_used_cells = null

const NORMAL_WALL_NORTH = 16
const NORMAL_WALL_WEST = 10
const NORMAL_WALL_EAST = 0
const NORMAL_WALL_SOUTH = 22

const EXTERN_CORNER_TOP_RIGHT = 10
const EXTERN_CORNER_TOP_LEFT = 16
const EXTERN_CORNER_BOTTOM_RIGHT = 0
const EXTERN_CORNER_BOTTOM_LEFT = 22

func get_adjacent_floor_tiles(origin: Vector3) -> int:
	var tiles = 0
	var addition = 1
	for adjacent in adjacent_transforms:
		if (origin + adjacent) in original_used_cells:
			tiles += addition
		addition *= 2

	return tiles

func add_walls():
	# Iterate over every floor tile on floor 0, and check each adjacent space
	# for an empty tile. Add a wall as necessary.
	
	original_used_cells = get_used_cells()
	
	for tile in original_used_cells:
		for adjacent in adjacent_transforms:
			var cell = tile + adjacent
			if get_cell_item(cell.x, cell.y, cell.z) == -1:
				# print("Empty space: " + str(cell.x) + ", "+ str(cell.y) + ", "+ str(cell.z) + ", ")
				var found_tiles = get_adjacent_floor_tiles(Vector3(cell.x, cell.y, cell.z))
				
				# 1  2  4
				# 8     16
				# 32 64 128
				
				# 1 0 0
				# 1   0
				# 1 1 1
				
				match found_tiles:
					# mid, mid-left, mid-right, all
					2, 3, 6, 7: # North facing (bottom) wall.
						set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_NORTH)
					64, 96, 192, 224: # South facing (top) wall.
						set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_SOUTH)
					16, 20, 144, 148: # East facing (right) wall.
						set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_EAST)
					8, 9, 40, 41: # West facing (left) wall.
						set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_WEST)
					# External corners
					4:
						set_cell_item(cell.x, cell.y, cell.z, 2, 16)
					32:
						set_cell_item(cell.x, cell.y, cell.z, 2, 22)
						set_cell_item(cell.x-1, cell.y, cell.z, -1)
						set_cell_item(cell.x, cell.y, cell.z+1, -1)
						#TODO: wall tiles get re-added after removal. add corner tiles last?
					128:
						set_cell_item(cell.x, cell.y, cell.z, 2, 0)
					1:
						set_cell_item(cell.x, cell.y, cell.z, 2, 10)
					# Internal corners
					22:
						print("fhdsjkfh")
					11:
						print("Top left internal corner")
					104:
						print("Bottom left internal corner")
					208:
						print("Bottom right internal corner")
					_:
						print("Nothing found for " + str(found_tiles))
