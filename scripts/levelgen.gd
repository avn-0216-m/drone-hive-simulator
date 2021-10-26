extends Spatial

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
		"add_from": Vector2(-2,-2),
		"add_to": Vector2(2,2),
		"collision": Vector3(0,0,0)
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

var start_tile = null
var entry_tile_pos: Vector3
var exit_tile = Vector3(0,0,0)
var room_size_x = 0
var room_size_z = 0

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var multimeshes = get_node("Geometry/Multimeshes")

onready var bodies = get_node("Geometry/Bodies")
onready var floors = get_node("Geometry/Bodies/Floor")
onready var walls = get_node("Geometry/Bodies/Walls")
onready var extern_corners = get_node("Geometry/Bodies/ExternalCorners")
onready var intern_corners = get_node("Geometry/Bodies/InternalCorners")
onready var objects = get_node("Objects")
onready var collision_checks = get_node("CollisionChecks")


# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.

var difficulty: int = 0
var tasks: int = 1

func _ready():
	
	new_level()
	# when instanced, grab the camera and point it to your wall materials
	# that way, every new level will replace the old levels material references
	# in the camera. very beautiful, very powerful.

	var camera = get_node("../CameraContainer/MainCamera")
	
	camera.wall_mat = multimeshes.walls.multimesh.mesh.surface_get_material(0)
	camera.extern_mat = multimeshes.extern_corners.multimesh.mesh.surface_get_material(0)
	camera.intern_mat = multimeshes.intern_corners.multimesh.mesh.surface_get_material(0)

func get_adjacent_floor_tiles(origin: Vector3) -> int:
	var tiles = 0
	var addition = 1
	for adjacent in adjacent_transforms:
		if (origin + adjacent) in original_used_cells:
			tiles += addition
		addition *= 2

	return tiles

func add_walls_to_gridmap():
	# Iterate over every floor tile on floor 0, and check each adjacent space
	# for an empty tile. Add a wall as necessary.
	
	original_used_cells = gridmap.get_used_cells()
	if start_tile != null:
		original_used_cells += [start_tile]
	# start tile is empty for the elevator to come down into
	# so it needs to be added to the used cells so walls still generate
	# correctly around it.
	
	for tile in original_used_cells:
		
		# skip objects not on the floor (level 0)
		if tile.y > 0:
			continue
		
		for adjacent in adjacent_transforms:
			var cell = tile + adjacent
			if gridmap.get_cell_item(cell.x, cell.y, cell.z) == -1 or cell == start_tile:
				var found_tiles = get_adjacent_floor_tiles(Vector3(cell.x, cell.y, cell.z))
				
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

func generate_floor(difficulty: int):
	room_size_x = rng.randi_range(5, 5 + difficulty)
	room_size_z = rng.randi_range(5, 5 + difficulty)
	
	for tile_x in range(0, room_size_x):
		for tile_z in range(0,room_size_z):
			gridmap.set_cell_item(tile_x, 0, tile_z, 0)
	
func cut_holes():
	return
	
func add_additional_rooms():
	return
	
func add_object_to_gridmap(pos: Vector3, item_index):
	
	# add an area
	# check if area intersects
	# if true, don't add object/move it
	# if false, add object to gridmap
	
	var area = Area.new()
	var collision = CollisionShape.new()
	var box_shape = BoxShape.new()
	collision.shape = box_shape
	area.add_child(collision)
	
	print("ADDING AREA CHECK")
	
	print(area)
	print(collision)
	
	collision_checks.add_child(area)
	
	print("ADDED AREA CHILD")
	print(collision_checks.get_children())
	
	if item_index >= len(meshlibrary):
		return
	
	var item_data = meshlibrary[item_index]
	
	collision.translation = gridmap.map_to_world(pos.x, pos.y, pos.z)
	
	collision.scale = item_data.get("collision_scale", Vector3(1,1,1))
	collision.translation += item_data.get("collision_translation", Vector3(0,0,0))
	
	
	
	gridmap.set_cell_item(pos.x, pos.y, pos.z, item_index)
	
	print("adding object")
	return
	
func set_toybox_and_toyhole():
	var floor_tiles = gridmap.get_used_cells()
	floor_tiles.shuffle()
	match(difficulty):
		0: # Don't spawn entry tile on first level.
			var exit_tile = floor_tiles[1]
			#gridmap.set_cell_item(exit_tile.x, 0, exit_tile.z, 5)
			add_object_to_gridmap(exit_tile, 5)
		_:
			var exit_tile = floor_tiles[1]
			start_tile = floor_tiles[0]
			#gridmap.set_cell_item(exit_tile.x, 0, exit_tile.z, 5)
			add_object_to_gridmap(exit_tile, 5)
			#gridmap.set_cell_item(start_tile.x, 0, start_tile.z, 7)
			add_object_to_gridmap(start_tile, 7)
			entry_tile_pos = gridmap.map_to_world(start_tile.x, start_tile.y, start_tile.z)


func instance_gridmap_object(cell, cell_item, parent):
	
	# don't retrieve invalid objects
	# TODO: why the fuck does my mesh library have an item 6
	if cell_item >= len(meshlibrary):
		return
	
	var object = meshlibrary[cell_item]
	if object.get("source", null) == null:
		return
	
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

func clear_collisions():
	# Removes all collision test areas from CollisionChecks node.
	for area in get_node("CollisionChecks").get_children():
		area.queue_free()

func add_tasks():
	print("Adding tasks.")

func new_level():
	
	difficulty = get_parent().difficulty
	
	# clear all existing nodes and variables
	bodies.reset()
	
	# clear multimeshes
	multimeshes.reset()
	
	# gridmap setup
	randomize()
	gridmap.clear()
	generate_floor(difficulty)
	if difficulty > 3:
		cut_holes()
	if difficulty > 6:
		add_additional_rooms()
	set_toybox_and_toyhole()
	add_tasks()
	
	# first pass: instance all NON LEVEL GEOMETRY objects, add or remove required tiles
	# second pass: instance updated level geometry.
	
	# FIRST PASS
	for cell in gridmap.get_used_cells():
		var cell_item = gridmap.get_cell_item(cell.x, cell.y, cell.z)
		if cell_item > 3:
				instance_gridmap_object(cell, cell_item, objects)
				
	add_walls_to_gridmap()
				
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
		
	gridmap.clear()
	
	# multi mesh renderers get fucky if you set them up at any
	# translation besides 0,0,0. so set that first, then reset position.
	var previous_translation = translation
	translation = Vector3(0,0,0)
	multimeshes.init_multimeshes()
	translation = previous_translation
