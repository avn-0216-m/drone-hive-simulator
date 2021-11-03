extends Spatial

var placements: Array = []
const frame_wait_time: int = 5

var good_tiles: Array = [] # List of Vector3s representing known clear tile co-ords for placement optimization

var bird_factor: int = 3 # How often Anna appears. (Default: once every 3 levels)

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
	
enum State {PLACING, INSTANCING, DONE}
var state = State.PLACING

var meshlibrary: Array = [
	{ # 0: floor tile
		"source": load("res://objects/tiles/Floor.tscn"),
	},
	{ # 1: wall tile
		"source": load("res://objects/tiles/Wall.tscn"),
	},
	{ # 2: external corner
		"source": load("res://objects/tiles/ExternalCorner.tscn"),
	},
	{ # 3: internal corner
		"source": load("res://objects/tiles/InternalCorner.tscn")
	},
	{ # 4: spatial flower. debug item. spawns a flower with a lot of space around it.
		"source": load("res://objects/Flower.tscn"),
		"offset": Vector3(0,2,0),
		"add_from": Vector2(-1,-1),
		"add_to": Vector2(1,1),
		"collision_scale": Vector3(2,2,2)
	},
	{ # 5: toybox. origin tile is top mid.
		"source": load("res://objects/StorageBox.tscn"),
		"add_from": Vector2(-2,-2),
		"add_to": Vector2(2,4),
		"remove_from": Vector2(-1,0),
		"remove_to": Vector2(1,1),
		"collision_translation": Vector3(0,0,2),
		"collision_scale": Vector3(4,1,6)
	},
	{ # 6: Placeholder. Spawns nothing.
	},
	{ # 7: toyhole. 0841's lol. Fits the toybox coming in from the prev level.
		"source": load("res://objects/Toyhole.tscn"),
		"add_from": Vector2(-5,-5),
		"add_to": Vector2(5,5),
		"remove_from": Vector2(-1,0),
		"remove_to": Vector2(1,1),
		"collision_scale": Vector3(5,1,5)
	},
	{ # 8: cube. put on button
		"source": load("res://objects/WeightedCube.tscn"),
		"add_from": Vector2(-1,-1),
		"add_to": Vector2(1,1),
		"offset": Vector3(0,3,0)
	},
	{ # 9: button. put cube on.
		"source": load("res://objects/WeightedButton.tscn"),
		"add_from": Vector2(-1,-1),
		"add_to": Vector2(1,1),
		"offset": Vector3(0,0,0)
	},
	{ # 10: Anna. Anna is 10/10 best birb.
		"source": load("res://objects/Anna.tscn"),
		"offset": Vector3(0,1,0),
		"collision_scale": Vector3(1,1,1),
		"add_from": Vector2(-1,-1),
		"add_to": Vector2(1,1)
	}
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

var level_size = Vector2(0,0)
var entry_tile_pos: Vector3

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var multimeshes = get_node("Geometry/Multimeshes")
onready var task_manager = get_node("../Tasks")
onready var bodies = get_node("Geometry/Bodies")
onready var floors = get_node("Geometry/Bodies/Floor")
onready var walls = get_node("Geometry/Bodies/Walls")
onready var extern_corners = get_node("Geometry/Bodies/ExternalCorners")
onready var intern_corners = get_node("Geometry/Bodies/InternalCorners")
onready var objects = get_node("Objects")
onready var collision_checks = get_node("CollisionChecks")

# combined wall mesh not built from gridmap walls
onready var wall_mesh = get_node("WallMesh")


# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.

var difficulty: int = 0
var num_tasks: int = 1

func _ready():
	
	new_level()
	# when instanced, grab the camera and point it to your wall materials
	# that way, every new level will replace the old levels material references
	# in the camera. very beautiful, very powerful.

	var camera = get_node("../CameraContainer/MainCamera")
	
	camera.wall_mat = multimeshes.walls.multimesh.mesh.surface_get_material(0)
	camera.extern_mat = multimeshes.extern_corners.multimesh.mesh.surface_get_material(0)
	camera.intern_mat = multimeshes.intern_corners.multimesh.mesh.surface_get_material(0)

func get_adjacent_tiles(origin: Vector3) -> int:
	var tiles = 0
	var addition = 1
	
	var used_cells = gridmap.get_used_cells()
	
	for adjacent in adjacent_transforms:
		if (origin + adjacent) in used_cells:
			tiles += addition
		addition *= 2

	return tiles

func get_adjacent_edge_tile(origin: Vector3, visited: Array):
	"""
	Given a Vector3 gridmap co-ordinate and array of visited tiles,
	Return the first co-ordinate for an edge tile not in the visited array.
	Returns null if none found.
	"""
	
	#if visited.size() == 10: return null
	
	# TODO: you need to look for EMPTY TILES with FLOOR TILES adjacent
	# as opposed to empty tiles with nothing adjacent (they are not the outline)
	
	for adjacent in adjacent_transforms:
		var translated = origin + adjacent
		if get_adjacent_tiles(translated) != 255 and !(translated in visited) and gridmap.get_cell_item(translated.x, translated.y, translated.z) == 0:
			print("NEXT EDGE FOUND")
			return translated
	
	print("NO EDGE TILES FOUDN FROM THIS POSITION KYS")
	
	return null

func create_wall_mesh():
	
	# find start tile (ABITRARYTYYG)
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) # every 3 verticies is rendered as a tri

	
	
	var visited_tiles: Array = []
	var next_tile = Vector3(0,0,0)
	
	# find start tile:
	for cell in gridmap.get_used_cells():
		if gridmap.get_cell_item(cell.x, cell.y, cell.z) == 0 and get_adjacent_tiles(Vector3(cell.x, cell.y, cell.z)) != 255:
			print("Start tile for wall mesh gen found: " + str(next_tile))
			next_tile = Vector3(cell.x, cell.y, cell.z)
			break
	
	while(next_tile != null):
		
		visited_tiles.append(next_tile)
		print("ITERATING MESH ADDITION")
		
		# add mesh verticies here
		var tile_world_pos = gridmap.map_to_world(next_tile.x, next_tile.y, next_tile.z)
		print(tile_world_pos)
		st.add_vertex(tile_world_pos + Vector3(-1,0,0))
		st.add_vertex(tile_world_pos + Vector3(-1,3,0))
		st.add_vertex(tile_world_pos + Vector3(1,0,0))
		
		# call this last for the while loop
		next_tile = get_adjacent_edge_tile(next_tile, visited_tiles)
		
	wall_mesh.mesh = st.commit()
	wall_mesh.create_trimesh_collision()


func add_walls_to_gridmap():
	# Iterate over every floor tile on floor 0, and check each adjacent space
	# for an empty tile. Add a wall as necessary.
	
	original_used_cells = gridmap.get_used_cells()
	# start tile is empty for the elevator to come down into
	# so it needs to be added to the used cells so walls still generate
	# correctly around it.
	
	for tile in original_used_cells:
		
		# skip objects not on the floor (level 0)
		if tile.y > 0:
			continue
		
		for adjacent in adjacent_transforms:
			var cell = tile + adjacent
			if gridmap.get_cell_item(cell.x, cell.y, cell.z) == -1:
				var found_tiles = get_adjacent_tiles(Vector3(cell.x, cell.y, cell.z))
				
				# 1  2  4
				# 8     16
				# 32 64 128
				
				match found_tiles:
					7: # North facing (bottom) wall.
						gridmap.set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_NORTH)
					224: # South facing (top) wall.
						gridmap.set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_SOUTH)
					148: # East facing (right) wall.
						gridmap.set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_EAST)
					41: # West facing (left) wall.
						gridmap.set_cell_item(cell.x, cell.y, cell.z, WALL_INDEX, NORMAL_WALL_WEST)
					# External corners
					4:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 2, 16)
					32:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 2, 22)
					128:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 2, 0)
					1:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 2, 10)
					22, 150, 151: # internal corners
						print("setting internal corner")
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 22)
					11, 14, 43, 47: 
						print("setting internal corner")
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 0)
					104, 105, 232, 233:
						print("setting internal corner")
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 16)
					208, 212, 240, 244:
						print("setting internal corner")
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 10)

func generate_floor_prototype(difficulty: int):
	
	level_size.x = rng.randi_range(5, 5 + difficulty)
	level_size.y = rng.randi_range(5, 5 + difficulty)
	
	for tile_x in range(0, level_size.x):
		for tile_z in range(0,level_size.y):
			gridmap.set_cell_item(tile_x, 0, tile_z, 0)
			good_tiles.append(Vector3(tile_x, 0, tile_z))
	
func check_for_collisions(pos: Vector3, item_index):
	
	# add an area
	# check if area intersects
	# if true, don't add object/move it
	# if false, add object to gridmap
	
	var area = Area.new()
	var collision = CollisionShape.new()
	var box_shape = BoxShape.new()
	collision.shape = box_shape
	area.add_child(collision)
	collision_checks.add_child(area)
	
	if item_index >= len(meshlibrary):
		return
	
	var item_data = meshlibrary[item_index]
	
	collision.translation = gridmap.map_to_world(pos.x, pos.y, pos.z)
	
	collision.scale = item_data.get("collision_scale", Vector3(1,1,1))
	collision.translation += item_data.get("collision_translation", Vector3(0,0,0))
	
func set_toybox_and_toyhole():
	
	# debug code, remove the return later
	# you dunce
	
	# TODO: set toyhole collision checker
	
	var floor_tiles = gridmap.get_used_cells()
	floor_tiles.shuffle()
	match(difficulty):
		0: # Don't spawn entry tile on first level.
			place(5)
		_:
			place(5)
			place(7)

func place(item_index):
	
	print("adding place req for: " + str(item_index))
	
	var item_data = meshlibrary[item_index]
	
	var req = placement_req.new(item_index)
	
	req.area.scale = item_data.get("collision_scale", Vector3(1,1,1))
	
	# add area node to tree
	collision_checks.add_child(req.area)
	placements.append(req)

func instance_gridmap_object(cell, cell_item, parent) -> Node:
	
	if cell_item >= len(meshlibrary):
		print("Couldn't instance item. Index too high.")
		return null
	
	var object = meshlibrary[cell_item]
	if object.get("source", null) == null:
		print("Couldn't instance item. Source not found.")
		return null
	
	var instance = object.source.instance()
	
	# set translation + offset if available
	instance.translation = gridmap.map_to_world(cell.x, cell.y, cell.z)
	instance.translation += object.get("offset", Vector3(0,0,0))
	
	# add additional tiles
	var add_from = object.get("add_from", null)
	var add_to = object.get("add_to", null)
	if add_from != null and add_to != null:
		var origin = Vector3(cell.x, cell.y, cell.z)
		for x in range(add_from.x, add_to.x + 1):
			for z in range(add_from.y, add_to.y + 1):
				gridmap.set_cell_item(x+origin.x,0,z+origin.z,0)
				good_tiles.erase(Vector3(x+origin.x,0,z+origin.z))
				
	# remove excess tiles. tiles are replaced with placeholder items so
	# walls are not spawned around the item.
	var remove_from = object.get("remove_from", null)
	var remove_to = object.get("remove_to", null)
	if remove_from != null and remove_to != null:
		print("removing tiles!!")
		var origin = Vector3(cell.x, cell.y, cell.z)
		for x in range(remove_from.x, remove_to.x + 1):
			for z in range(remove_from.y, remove_to.y + 1):
				gridmap.set_cell_item(x+origin.x,0,z+origin.z,6)
				good_tiles.erase(Vector3(x+origin.x,0,z+origin.z))
		
	
	# set name
	instance.name += " (x" + str(cell.x) + ",z" + str(cell.z) + ")"

	# set rotation
	match(gridmap.get_cell_item_orientation(cell.x, cell.y, cell.z)):
		10:
			instance.rotation_degrees.y = 180
		16:
			instance.rotation_degrees.y = 90
		22:
			instance.rotation_degrees.y = 270
	
	# add child
	parent.add_child(instance)
	
	return instance

func clear_collisions():
	# Removes all collision test areas from CollisionChecks node.
	for area in get_node("CollisionChecks").get_children():
		area.queue_free()

func add_tasks():
	place(8)
	place(9)

func instance_gridmap():
	# first pass: instance all NON LEVEL GEOMETRY objects, add or remove required tiles
	# second pass: instance updated level geometry.
	# FIRST PASS
	for object in placements:
		
		print("instancing: " + str(object.index))
		
		match(object.index):
			0,1,2,3:
				pass
			5:
				task_manager.exit_box = instance_gridmap_object(object.pos, object.index, objects)
			_:
				var instanced_node = instance_gridmap_object(object.pos, object.index, objects)
				print("result: " + str(instanced_node.name))
				if instanced_node != null and instanced_node.has_signal("task_complete"):
					task_manager.add_task_node(instanced_node)
				
	for cell in gridmap.get_used_cells():
		var cell_item = gridmap.get_cell_item(cell.x, cell.y, cell.z)
		match(cell_item):
			0:
				# floor
				instance_gridmap_object(cell, cell_item, floors)
			1:
				# wall
				instance_gridmap_object(cell, cell_item, walls)
			2:
				# external corner
				instance_gridmap_object(cell, cell_item, extern_corners)
			3:
				# internal corner
				instance_gridmap_object(cell, cell_item, intern_corners)
	
	# multi mesh renderers get fucky if you set them up at any
	# translation besides 0,0,0. so set that first, then reset position.
	var previous_translation = translation
	translation = Vector3(0,0,0)
	multimeshes.init_multimeshes()
	translation = previous_translation
	
	state = State.DONE

func new_level():
	
	difficulty = get_parent().difficulty
	
	# clear previous tasks
	task_manager.tasks.clear()
	
	# clear placements from previous level
	placements.clear()
	
	# clear known good tiles
	good_tiles.clear()
	
	# clear all geometry bodies
	bodies.reset()
	
	# delete all level objects
	for node in objects.get_children():
		node.queue_free()
	
	# clear multimeshes
	multimeshes.reset()
	
	# gridmap setup
	randomize()
	gridmap.clear()
	generate_floor_prototype(difficulty)
	set_toybox_and_toyhole()
	add_tasks()
	
	
	if true or difficulty % bird_factor == 0: # add anna if on a birdy level
		place(10)
	
	state = State.PLACING
	
func generate_new_placement_pos(req):
	
	rng.randomize()
	
	# add_from MUST represent top left corner & add_to must represent bottom right corner
	
		#"add_from": Vector2(-2,-2),
		#"add_to": Vector2(2,4),
	
	# item data (add_from/to) is required to calculate "stray"
	# "stray" is how far an item can be placed off the edge of the map
	# for example, if a toybox places 2 tiles to the right of it, that means
	# it can also be placed 2 tiles to the left of the map (e.g (-2,3))
	# while still being connected to the map
	
	var item_data = meshlibrary[req.index]
	
	var new_pos = Vector3(0,1,0)
	
	new_pos.x = rng.randi_range(0 + item_data.get("add_from", Vector2(0,0)).x, level_size.x + item_data.get("add_to", Vector2(0,0)).x)
	new_pos.z = rng.randi_range(0 - item_data.get("add_to", Vector2(0,0)).y, level_size.y + item_data.get("add_from", Vector2(0,0)).y)
	
	req.pos = new_pos
	req.area.translation = gridmap.map_to_world(req.pos.x, req.pos.y, req.pos.z)
	
	# x in range(0 - req.to.x, level_size.x + abs(req.to.y):
	# y in range(0 + abs(req.from.x), level_size.y + req.from.y):
	
	
func _physics_process(delta):
	
	# TODO: optimization. order all objects from smallest to largest, move the smaller ones first.
	
	var all_positions_safe: bool = true
	var moved_area: bool = false
	
	if state == State.PLACING:
		print("ITERATION")
		for placement in placements:
			placement.countdown = max(0, placement.countdown - 1)
			if placement.countdown == 0 and placement.safe == false:
				placement.safe = true
			if placement.pos == null:
				print("assigning random gridmap position")
				generate_new_placement_pos(placement)
			if !placement.area.get_overlapping_areas().empty() and !moved_area:
				print("Overlap found, moving area")
				moved_area = true
				placement.countdown = frame_wait_time
				placement.safe = false
				generate_new_placement_pos(placement)
			if placement.safe == false:
				all_positions_safe = false
				
				
		if all_positions_safe:
			print("ALL POSITIONS SAFE")
			print(placements)
			
			for placement in placements:
				gridmap.set_cell_item(placement.pos.x, placement.pos.y, placement.pos.z, placement.index)
				if placement.index == 7: # toyhole
					print("setting toyhole beep hfdjkfhsdk")
					entry_tile_pos = gridmap.map_to_world(placement.pos.x, placement.pos.y, placement.pos.z)
			
			state = State.INSTANCING
			clear_collisions()
			instance_gridmap()
			print("abt to call create wall mesh ---------------------")
			create_wall_mesh()
			gridmap.clear()
			
func overlapping_area_detected(area):
	for placement in placements:
		if area == placement.area:
			print("matching naughty area found")
			placement.countdown = frame_wait_time
			placement.area.translation = Vector3(90,90,90)
