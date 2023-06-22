extends Spatial



var respawn_point: Vector3 = Vector3(0,5,0)

var level: int = 3

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

var level_size = Vector2(0,0)
var entry_tile_pos: Vector3

var rng = RandomNumberGenerator.new()

onready var gridmap = get_node("GridMap")
onready var geometry = get_node("Geometry")
onready var objects = get_node("Objects")

# Objects are mobile complexities with programming and meshes that cannot be
# represented in the body + multimesh combo.

func recursively_assign(root: Node, task):
	if root.get_child_count() == 0:
		return
	else:
		for child in root.get_children():
			if child is Interactable:
				child.task = task
			recursively_assign(child, task)

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

func spawn_rooms():
	return
	
func spawn_hallway():
	# hallways should be able to go from room to room in two lines, with a
	# maximum of one 90-degree angle.
	# hallways should find a node, then find the next closest valid node.
	# in this case. valid nodes include doorways and junctions (90-degree
	# angles in hallways).
	return
