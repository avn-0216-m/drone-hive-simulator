extends Spatial



var respawn_point: Vector3 = Vector3(0,5,0)

var level: int = 10

var known_tiles: Array = []

var TileData = preload("res://scripts/data/TileData.gd")
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
	NEPost = 4, 
	NWPost = 1, 
	SEPost = 128, 
	SWPost = 32
	}

var level_size = Vector2(0,0)
var entry_tile_pos: Vector3

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var geometry = get_node("Geometry")
onready var objects = get_node("Objects")

# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.

func _ready():
	
	var camera = get_node("../Camera")
	
#	camera.wall_mat = multimeshes.walls.multimesh.mesh.surface_get_material(0)
#	camera.extern_mat = multimeshes.extern_corners.multimesh.mesh.surface_get_material(0)
#	camera.intern_mat = multimeshes.intern_corners.multimesh.mesh.surface_get_material(0)
	
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
	
	level += 1
	
	a_reset_level()
	a_add_floor_to_gridmap()
	a_add_tasks_to_gridmap()
	a_add_walls_to_gridmap()
	a_instance_gridmap()
	
func a_reset_level():
	
	print("Resetting level.")
	
	# delete all level objects
	for node in objects.get_children():
		node.queue_free()
	
	# delete everything on gridmap
	randomize()
	gridmap.clear()

func generate_floor_size():
	return 3

func a_add_floor_to_gridmap():
	
	print("Adding floor to gridmap")
	
	level_size.x = rng.randi_range(5, 5 + level)
	level_size.y = rng.randi_range(5, 5 + level)
	
	for tile_x in range(0, level_size.x):
		for tile_z in range(0,level_size.y):
			set_floor_tile(tile_x, 0, tile_z)

func placeholder_in_valid_position(origin, area) -> bool:
	# check to see if object area has ANY "do not place" signs
	for x in range(origin.x, origin.x + area.x + 1):
		for z in range(origin.z, origin.z + area.y + 1):
			if gridmap.get_cell_item(x,2,z) == MeshLib.Data.DONOTPLACE:
				return false
	return true
	
func flatten_placeholders(tasks: Array) -> Array:
	var flattened = []
	for task in tasks:
		for placeholder in task.placeholders:
			flattened.append(placeholder)
	
	randomize()
	flattened.shuffle()
	return flattened

func a_add_tasks_to_gridmap():
	print("Adding tasks to gridmap")
	
	for placeholder in flatten_placeholders(TaskManager.generate_task_list(level)):
		
		# find start tile
		rng.randomize()
		known_tiles.shuffle()
		
		var origin: Vector3 = Vector3(0,0,0)
		
		# Error prevention when debugging if I forget to generate floor tiles
		# manually.
		if known_tiles != []:
			origin = known_tiles[0]
		
		while !placeholder_in_valid_position(origin, placeholder.area):
			rng.randomize()
			if rng.randi() % 2 == 0:
				origin.x += 1
			else:
				origin.z += 1
			# If a "do not place" is found, travel right
			# until a gap is found, then place the object placeholder there.
			# Allows for dynamic levels that extend beyond the original level size
			# based on level.
			# "bump" the object right until it fits in place.
		
		#Add additional tiles
		for x in range(origin.x, origin.x + placeholder.area.x + 1):
			for z in range(origin.z, origin.z + placeholder.area.y + 1):
				set_floor_tile(x,0,z) # set tile
				gridmap.set_cell_item(x,2,z,3) # set "do not place" signs to prevent overlapping task objects
		
		#Add object placeholder
		gridmap.set_cell_item(origin.x,1,origin.z,placeholder.index)
		# Update placeholder position.
		placeholder.pos = Vector3(origin.x, 1, origin.z)
	
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
				var adjacent_tiles = get_adjacent_tiles(Vector3(cell.x, cell.y, cell.z), floor_tiles)
				var data = TileData.patterns[adjacent_tiles]
				
				if data == null:
					continue
				else:
					gridmap.set_cell_item(cell.x, cell.y, cell.z, data[0], data[1])

func set_floor_tile(x: float, y: float, z: float):
	gridmap.set_cell_item(x, y, z, MeshLib.Data.FLOOR)
	known_tiles.append(Vector3(x,y,z))

func a_instance_gridmap():
			
	# Add multimeshes and colliders
	for cell in gridmap.get_used_cells():
		
		# Delete placeholder tiles (all on floor 2)
		if cell.y == 2:
			gridmap.set_cell_item(cell.x, cell.y, cell.z, -1)
		
		var item = gridmap.get_cell_item(cell.x, cell.y, cell.z)
		var rot = gridmap.get_cell_item_orientation(cell.x, cell.y, cell.z)
		if item in [
			MeshLib.Data.FLOOR,
			MeshLib.Data.WALL,
			MeshLib.Data.POST,
			MeshLib.Data.CORNER,
			MeshLib.Data.FLOORNOWALLS,
		]:
			geometry.add_collider(gridmap.map_to_world(cell.x, cell.y, cell.z), item, rot)
			

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
	gridmap.clear()
	geometry.init_multimeshes()
