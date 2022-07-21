extends Spatial

var placements: Array = []
const frame_wait_time: int = 5

var respawn_point: Vector3 = Vector3(0,5,0)

var bird_factor: int = 3 # How often Anna appears. (Default: once every 3 levels)

var difficulty: int = 30

export(GDScript) var MeshLib

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

# 1  2  4
# 8  x  16
# 32 64 128 

enum Pattern {
	Box = 2 + 8 + 16 + 64, 
	NCurve = 2 + 8 + 16, 
	SCurve = 8 + 16 + 64, 
	ECurve = 2 + 16 + 64, 
	WCurve = 2 + 8 + 64, 
	NECorner = 2 + 16, 
	NWCorner = 2 + 8, 
	SECorner = 16 + 64, 
	SWCorner = 8 + 64,
	DoubleVert = 8 + 16,
	DoubleHori = 2 + 64,
	NWall = 2, 
	SWall = 64, 
	EWall = 16, 
	WWall = 8,
	NEPost = 1, 
	NWPost = 4, 
	SEPost = 128, 
	SWPost = 32
	}


enum WallOrient {East=0, West=10, North=16, South=22}
enum PostOrient {NorthEast=0, NorthWest=10, SouthEast=16, SouthWest=22}
enum CornerOrient {NorthEast=22, NorthWest=0, SouthWest=16, SouthEast=10}
enum CurveOrient {East=22, West=16, North=0, South=10}
enum DoubleOrient {Hori=22, Vert=0}

var level_size = Vector2(0,0)
var entry_tile_pos: Vector3

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var multimeshes = get_node("Geometry/Multimeshes")
onready var bodies = get_node("Geometry/Bodies")
onready var floors = get_node("Geometry/Bodies/Floor")
onready var walls = get_node("Geometry/Bodies/Walls")
onready var extern_corners = get_node("Geometry/Bodies/ExternalCorners")
onready var intern_corners = get_node("Geometry/Bodies/InternalCorners")
onready var objects = get_node("Objects")

# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.

func _ready():
	
	var camera = get_node("../CameraContainer/MainCamera")
	
	camera.wall_mat = multimeshes.walls.multimesh.mesh.surface_get_material(0)
	camera.extern_mat = multimeshes.extern_corners.multimesh.mesh.surface_get_material(0)
	camera.intern_mat = multimeshes.intern_corners.multimesh.mesh.surface_get_material(0)
	
	#return # return early, use debug buttons to generate level
	
	# new_level()
	# when instanced, grab the camera and point it to your wall materials
	# that way, every new level will replace the old levels material references
	# in the camera. very beautiful, very powerful.

func get_adjacent_tiles(origin: Vector3, floor_tiles) -> int:
	var tiles = 0
	var addition = 1
	
	for adjacent in adjacent_transforms:
		if (origin + adjacent) in floor_tiles:
			tiles += addition
		addition *= 2

	return tiles

func new_level():
	
	difficulty += 1
	
	a_reset_level()
	a_add_floor_to_gridmap()
	a_add_tasks_to_gridmap()
	a_add_walls_to_gridmap()
	a_instance_gridmap()
	
func a_reset_level():
	
	print("Resetting level.")
	
	# clear placements from previous level
	placements.clear()
	
	# clear all geometry bodies
	bodies.reset()
	
	# delete all level objects
	for node in objects.get_children():
		node.queue_free()
	
	# clear multimeshes
	multimeshes.reset()
	
	# delete everything on gridmap
	randomize()
	gridmap.clear()

func generate_floor_size():
	return 3

func a_add_floor_to_gridmap():
	
	print("Adding floor to gridmap")
	
	level_size.x = rng.randi_range(5, 5 + difficulty)
	level_size.y = rng.randi_range(5, 5 + difficulty)
	
	for tile_x in range(0, level_size.x):
		for tile_z in range(0,level_size.y):
			gridmap.set_cell_item(tile_x, 0, tile_z, 0)

func placeholder_in_valid_position(origin, area) -> bool:
	# check to see if object area has ANY "do not place" signs
	for x in range(origin.x, origin.x + area.x + 1):
		for y in range(origin.y, origin.y + area.y + 1):
			if gridmap.get_cell_item(x,2,y) == 3:
				return false
	return true
	
func flatten_placeholders(tasks: Array) -> Array:
	var flattened = []
	for task in tasks:
		for placeholder in task.placeholders:
			flattened.append(placeholder)
	
	flattened.shuffle()
	return flattened

func a_add_tasks_to_gridmap():
	print("Adding tasks to gridmap")
	
	for placeholder in flatten_placeholders(TaskManager.generate_task_list(difficulty)):
		
		# find start tile
		rng.randomize()
		var origin = Vector2(
			rng.randi_range(0 - placeholder.area.x, level_size.x),
			rng.randi_range(0 - placeholder.area.y, level_size.y - 1)
			)
		
		while !placeholder_in_valid_position(origin, placeholder.area):
			origin.x += 1
			# If a "do not place" is found, travel right
			# until a gap is found, then place the object placeholder there.
			# Allows for dynamic levels that extend beyond the original level size
			# based on difficulty.
			# "bump" the object right until it fits in place.
		
		#Add additional tiles
		for x in range(origin.x, origin.x + placeholder.area.x + 1):
			for y in range(origin.y, origin.y + placeholder.area.y + 1):
				gridmap.set_cell_item(x,0,y,0) # set tile
				gridmap.set_cell_item(x,2,y,3) # set "do not place" signs to prevent overlapping task objects
		
		#Add object placeholder
		gridmap.set_cell_item(origin.x,1,origin.y,placeholder.index)
		# Update placeholder position.
		placeholder.pos = Vector3(origin.x, 1, origin.y)
	
func a_add_walls_to_gridmap():

	# Iterate over every floor tile on floor 0, and check each adjacent space
	# for an empty tile. Add a wall as necessary.
	
	var floor_tiles = gridmap.get_used_cells()
	for tile in floor_tiles:
		if gridmap.get_cell_item(tile.x, tile.y, tile.z) != MeshLib.Data.FLOOR:
			floor_tiles.erase(tile)
	
	for tile in floor_tiles:
		
		# skip objects not on the floor (level 0)
		if tile.y != 0:
			continue
		
		for adjacent in adjacent_transforms:
			var cell = tile + adjacent
			if gridmap.get_cell_item(cell.x, cell.y, cell.z) == -1:
				var found_tiles = get_adjacent_tiles(Vector3(cell.x, cell.y, cell.z), floor_tiles)
				
				# 1  2  4
				# 8  X  16
				# 32 64 128
				
				if(found_tiles & Pattern.Box) >= Pattern.Box:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.BOX)
				elif(found_tiles & Pattern.NCurve) >= Pattern.NCurve:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CURVE, CurveOrient.North)
				elif(found_tiles & Pattern.SCurve) >= Pattern.SCurve:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CURVE, CurveOrient.South)
				elif(found_tiles & Pattern.ECurve) >= Pattern.ECurve:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CURVE, CurveOrient.East)
				elif(found_tiles & Pattern.WCurve) >= Pattern.WCurve:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CURVE, CurveOrient.West)
				elif(found_tiles & Pattern.NECorner) >= Pattern.NECorner:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CORNER, CornerOrient.NorthEast)
				elif(found_tiles & Pattern.NWCorner) >= Pattern.NWCorner:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CORNER, CornerOrient.NorthWest)
				elif(found_tiles & Pattern.SECorner) >= Pattern.SECorner:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CORNER, CornerOrient.SouthEast)
				elif(found_tiles & Pattern.SWCorner) >= Pattern.SWCorner:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.CORNER, CornerOrient.SouthWest)
				elif(found_tiles & Pattern.DoubleHori) >= Pattern.DoubleHori:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.DOUBLE, DoubleOrient.Hori)
				elif(found_tiles & Pattern.DoubleVert) >= Pattern.DoubleVert:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.DOUBLE, DoubleOrient.Vert)
				elif(found_tiles & Pattern.NWall) >= Pattern.NWall:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.WALL, WallOrient.North)
				elif(found_tiles & Pattern.SWall) >= Pattern.SWall:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.WALL, WallOrient.South)
				elif(found_tiles & Pattern.EWall) >= Pattern.EWall:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.WALL, WallOrient.East)
				elif(found_tiles & Pattern.WWall) >= Pattern.WWall:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, MeshLib.Data.WALL, WallOrient.West)

func a_instance_gridmap():
	# Delete all placeholder tiles on floor 2
	for cell in gridmap.get_used_cells():
		if cell.y == 2:
			gridmap.set_cell_item(cell.x, cell.y, cell.z, -1)
			
	# Add multimaps and colliders

	for task in TaskManager.get_active_tasks():

		
		for placeholder in task.placeholders:
			var instance = load(placeholder.source).instance()
			instance.translation = gridmap.map_to_world(placeholder.pos.x, placeholder.pos.y, placeholder.pos.z)
			# Add instance
			
			# Code sets task ID and variant on Interactables even if they are
			# the child of a spatial parent.
			if instance is Interactable:
				instance.task_id = task.task_id
				instance.variant = task.variant
			else:
				for child in instance.get_children():
					if child is Interactable:
						child.task_id = task.task_id
						child.variant = task.variant
					
			objects.add_child(instance)
			task.objects.append(instance)
			# Delete placeholders
			gridmap.set_cell_item(placeholder.pos.x, placeholder.pos.y, placeholder.pos.z, -1)
	
	UI.set_tasks(TaskManager.get_active_tasks())
