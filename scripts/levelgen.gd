extends Spatial

export var maximum_bump = 6

var respawn_point: Vector3 = Vector3(0,5,0)

var level: int = 3

var known_tiles: Array = []

onready var placeholders = get_node("Placeholders")
onready var hallway = get_node("Hallway")

var TileData = preload("res://scripts/data/TileData.gd")
export(GDScript) var MeshLib

var room_pool = [
	preload("res://objects/rooms/test1.tscn")
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
	
	spawn_rooms()
	
	return
	
	# new_level()
	# when instanced, grab the camera and point it to your wall materials
	# that way, every new level will replace the old levels material references
	# in the camera. very beautiful, very powerful.

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

func spawn_rooms():
	for i in range (0,2):
		var room = room_pool[0].instance()
		add_child(room)
		var offset = position_room(room)
		placeholders.add(room)
		hallway.mark_doors(room.get_doors())
		placeholders.clear_doorways(room.get_doors())
		
	placeholders.strip()
		
	hallway.placeholders = placeholders
	hallway.add_hallway()

func position_room(room):
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	var safe_spot = false
	var walls = room.walls.get_used_cells()
	while safe_spot != true:
		randomize()
		safe_spot = true
		for w in walls:
			# get tile world position
			# map world position to placeholder gridmap
			# check if tile item id = -1
			var world_pos = placeholders.map_to_world(w.x, w.y, w.z)
			world_pos = room.walls.to_global(world_pos)
			var ph = placeholders.world_to_map(world_pos)
			if placeholders.get_cell_item(ph.x, ph.y, ph.z) != -1:
				randomize()
				if randi() % 2 == 0:
					room.translation.x += rng.randi_range(3, maximum_bump) * 2
				else:
					room.translation.z += rng.randi_range(3, maximum_bump) * 2
				safe_spot = false
				break
	return room.translation

func spawn_hallways():
	return
	
