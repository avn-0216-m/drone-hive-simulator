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
var start_tile_pos: Vector3
var exit_tile = Vector3(0,0,0)
var room_size_x = 0
var room_size_z = 0

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var multimeshes = get_node("Multimeshes")

onready var body_container = get_node("Bodies")
onready var floor_body_container = get_node("Bodies/Floor")
onready var wall_body_container = get_node("Bodies/Walls")
onready var extern_body_container = get_node("Bodies/ExternalCorners")
onready var intern_body_container = get_node("Bodies/InternalCorners")
onready var floor_src = preload("res://objects/tiles/Floor.tscn")
onready var wall_src = preload("res://objects/tiles/Wall.tscn")
onready var extern_src = preload("res://objects/tiles/ExternalCorner.tscn")

# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.
onready var object_container = get_node("Objects")
onready var storage_box_src = preload("res://objects/StorageBox.tscn")

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
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 16)
					32:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 22)
					128:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 0)
					1:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 3, 10)
					22, 150, 151: # internal corners
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 4, 22)
					11, 14, 43, 47: 
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 4, 0)
					104, 105, 232, 233:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 4, 16)
					208, 212, 240, 244:
						gridmap.set_cell_item(cell.x, cell.y, cell.z, 4, 10)

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
	
func set_start_end_tile():
	var floor_tiles = gridmap.get_used_cells()
	floor_tiles.shuffle()
	match(difficulty):
		0: # Don't spawn entry tile on first level.
			var exit_tile = floor_tiles[1]
			gridmap.set_cell_item(exit_tile.x, 0, exit_tile.z, 6)
		_:
			var exit_tile = floor_tiles[1]
			start_tile = floor_tiles[0]
			gridmap.set_cell_item(exit_tile.x, 0, exit_tile.z, 6)
			gridmap.set_cell_item(start_tile.x, 0, start_tile.z, -1)
			start_tile_pos = gridmap.map_to_world(start_tile.x, start_tile.y, start_tile.z)


func instance_gridmap_object(object, cell, parent):
	var tile_inst = object.instance()
	tile_inst.translation = gridmap.map_to_world(cell.x, cell.y, cell.z)
	tile_inst.name = "x" + str(cell.x) + ", z" + str(cell.z)
	parent.add_child(tile_inst)
	match(gridmap.get_cell_item_orientation(cell.x, cell.y, cell.z)):
		10:
			tile_inst.rotation_degrees.y = 180
		16:
			tile_inst.rotation_degrees.y = 90
		22:
			tile_inst.rotation_degrees.y = 270

func add_tasks():
	print("Adding tasks.")

func new_level():
	
	difficulty = get_parent().difficulty
	
	# clear all existing nodes and variables
	body_container.reset()
	
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
	set_start_end_tile()
	add_walls_to_gridmap()
	add_tasks()
	
	# instance tiles into bodies
	for cell in gridmap.get_used_cells():
		var tile_inst = null
		match(gridmap.get_cell_item(cell.x, cell.y, cell.z)):
			0: # floor tile
				instance_gridmap_object(floor_src, cell, floor_body_container)
			1: # straight wall
				instance_gridmap_object(wall_src, cell, wall_body_container)
				#pass
			3: # external corner
				instance_gridmap_object(extern_src, cell, extern_body_container)
			6: # exit storagebox
				instance_gridmap_object(storage_box_src, cell, object_container)
		
	gridmap.clear()
	
	# multi mesh renderers get fucky if you set them up at any
	# translation besides 0,0,0. so set that first, then reset position.
	var previous_translation = translation
	translation = Vector3(0,0,0)
	multimeshes.init_multimeshes()
	translation = previous_translation
