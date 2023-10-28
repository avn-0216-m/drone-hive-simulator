extends Spatial

var respawn_point: Vector3 = Vector3(0,5,0)

var extra_rooms: int = 3
var level: int = 1 # rooms per floor = level + extra_rooms

var rooms = [] # Array of all room objects on current floor.

export var minimum_hallway: int = 12

onready var placeholders = get_node("Placeholders")
onready var hallway = get_node("Hallway")

var TileData = preload("res://scripts/data/TileData.gd")
export(GDScript) var MeshLib


# Room pool
# Key: The floor at which a room is introduced
# Value: The rooms
# TODO: Probably make this into a resource for tidiness.
var unlockable_rooms: Dictionary = {
	0: [
		preload("res://objects/rooms/test1.tscn"),
		preload("res://objects/rooms/test2.tscn")]
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
		add_child(obj)
		if obj.north != null:
			pool_north.append(src)
		if obj.south != null:
			pool_south.append(src)
		if obj.west != null:
			pool_west.append(src)
		if obj.east != null:
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
	
	while(len(potentials) != 0 and len(rooms) != level + extra_rooms):
		
		# 10: East, needs west.
		# ??? Unconfirmed ???
		# 0: West, needs east.
		# 16: North, needs south.
		# 22: South, needs north.
		
		# Get a potential
		rng = RandomNumberGenerator.new() # < TODO: Seed this with drone ID + level
		var p_start = potentials.pop_at(rng.randi() % len(potentials))
		var source_array = []
		match(p_start.orientation): 
			10:
				source_array = pool_west
			0:
				source_array = pool_east
			16:
				source_array = pool_south
			22:
				source_array = pool_north
		
		var next_room = source_array[rng.randi() % len(source_array)]
		print(next_room)
		
		var nr_obj = next_room.instance()
		add_child(nr_obj)
		
		# find where the Potential is relative to local (0,0,0) to obtain an offset
		# translate the room to the target + the offset?
		# ^ the cell is already an offset dumbass
		
		var p_end = null
		match(p_start.orientation):
			0:
				p_end = nr_obj.east 
			10:
				p_end = nr_obj.west
			16:
				p_end = nr_obj.south
			22:
				p_end = nr_obj.north
		
		
		print(p_start.offset)
		nr_obj.translation = p_start.room.translation
		nr_obj.translation.z = p_start.offset.z - p_end.offset.z # there's no fuckin way this works
		nr_obj.translation.x += minimum_hallway
		
		rooms.append(nr_obj)
		potentials += nr_obj.get_potentials()
		#potentials = [] # THIS IS A DEBUG THING DELETE IT IF YOU WANT THE LOOP TO WORK PROPERLY
		
	print("Floor generated")

	
	return
