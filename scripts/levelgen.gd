extends Spatial

var respawn_point: Vector3 = Vector3(0,5,0)

var extra_rooms: int = 3
var level: int = 1 # rooms per floor = level + extra_rooms

var rooms = [] # Array of all room objects on current floor.

export var minimum_hallway_length: int = 3

onready var placeholders = get_node("Placeholders")
onready var hallway = get_node("Hallway")

var TileData = preload("res://scripts/data/TileData.gd")
export(GDScript) var MeshLib


# Room pool
# Key: The floor at which a room is introduced
# Value: The rooms
var unlockable_rooms: Dictionary = {
	0: [preload("res://objects/rooms/test1.tscn")]
}
var pool_north: Array = []
var pool_south: Array = []
var pool_east: Array = []
var pool_west: Array = []
export var start_room: PackedScene

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

func reload_pool():
	# Sorts the pool based on if they have NSEW doors.
	
	pool_north = []
	pool_south = []
	pool_east = []
	pool_west = []
	
	var unlocked_rooms = []
	# Get all unlocked rooms
	for i in range(0,level):
		var unlocked = unlockable_rooms.get(i)
		for room in unlocked:
			unlocked_rooms.append(room)
	
	for src in unlocked_rooms:
		var obj = src.instance()
		if obj.north:
			pool_north.append(src)
		if obj.south:
			pool_south.append(src)
		if obj.west:
			pool_west.append(src)
		if obj.east:
			pool_east.append(src)
		obj.queue_free()
	
	
	print("Loaded " + str(len(unlocked_rooms)) + " room(s).")
	return unlocked_rooms

func _ready():
	
	reload_pool()
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
	
	var potentials = []
	
	# spawn start room
	# loop and add rooms until you hit the room limit for this floor
	# or until you run out of usable doorways
	
	# as rooms are added, grab each potential, add it to an array.
	# each loop, pick a new potential and attempt to add a room to it.
	# if the hallway is obstructed (check placeholder gridmap) then that means
	# there is a room in the way.
	# mark the potential for deletion.
	# otherwise, mark the potential for creation (turning it into a doorway)
	
	# do not instance doors until this loop is complete.
	# once loop is complete, loop through all rooms and instance a doorway or
	# a wall.
	
	var start_obj = start_room.instance()
	add_child(start_obj)
	
	potentials += start_obj.get_potentials()
	placeholders.add(start_obj)
	
	while(len(potentials) != 0 and len(rooms) != level):
		potentials = []
		
	print("Floor generated")

	
	return
