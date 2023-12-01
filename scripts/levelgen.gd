extends Spatial

var respawn_point: Vector3 = Vector3(0,5,0)

var extra_rooms: int = 10
var level: int = 1 # rooms per floor = level + extra_rooms

var rooms = [] # Array of all room objects on current floor.

export var minimum_hallway: int = 6

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
		preload("res://objects/rooms/test4.tscn"),
		preload("res://objects/rooms/test5.tscn"),
		preload("res://objects/rooms/test6.tscn"),
		preload("res://objects/rooms/testbedroom.tscn")]
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
		var unlocked = unlockable_rooms.get(i, [])
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
	print("North: " + str(len(pool_north)) + " room(s).")
	print("South: " + str(len(pool_south)) + " room(s).")
	print("East: " + str(len(pool_east)) + " room(s).")
	print("West: " + str(len(pool_west)) + " room(s).")
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
	rooms.append(start_obj)
	
	while(len(potentials) != 0 and len(rooms) != level + extra_rooms):
		
		print("Potentials: " + str(len(potentials)))
		print("Rooms: " + str(len(rooms)))
		
		# 10: East, needs west.
		# ??? Unconfirmed ???
		# 0: West, needs east.
		# 16: North, needs south.
		# 22: South, needs north.
		
		# Get a potential
		rng = RandomNumberGenerator.new() # < TODO: Seed this with drone ID + level
		rng.randomize()
		var p_start = potentials.pop_at(rng.randi() % len(potentials))
		var source_array = []
		match(p_start.orientation): 
			10:
				print("Potential: East")
				source_array = pool_west
			0:
				print("Potential: West")
				source_array = pool_east
			16:
				print("Potential: North")
				source_array = pool_south
			22:
				print("Potential: South")
				source_array = pool_north
		
		var next_room = source_array[rng.randi() % len(source_array)]
		
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
		
		# if desired orientation is horizontal (east/west)
		# if the next potential has a greater z value than the current potential, 
		# subtract the difference from the next rooms translation
		# otherwise, add it.
		# presumably, you can do the same thing for vertical but with x instead of z
		
		nr_obj.translation = p_start.room.translation
		

		var dif = Vector3(0,0,0)
		# Horizontal alignment
		dif.z = p_start.offset.z - p_end.offset.z
		dif.z = neg(dif.z) if p_end.offset.z > p_start.offset.z else abs(dif.z)
		# Vertical alignment
		dif.x = p_start.offset.x - p_end.offset.x
		dif.x = neg(dif.x) if p_end.offset.x > p_start.offset.x else abs(dif.x)
		
		nr_obj.translation += dif
		# Now we can start pushing away and making a hallway.
		

		if p_end.orientation in [0,10]:
			nr_obj.translation.x += neg(minimum_hallway) if p_end.offset.x > p_start.offset.x else abs(minimum_hallway)
		else:
			nr_obj.translation.z += neg(minimum_hallway) if p_end.offset.z > p_start.offset.z else abs(minimum_hallway)

		# Check placeholders and nudge if necessary.
		if placeholders.test(nr_obj):
			placeholders.add(nr_obj)
			rooms.append(nr_obj)
			potentials += nr_obj.get_potentials(p_end.cell)
			p_start.connected = p_end
			p_end.connected = p_start
			p_start.valid = true
			p_end.valid = true
		else:
			nr_obj.queue_free()

		#potentials = [] # THIS IS A DEBUG THING DELETE IT IF YOU WANT THE LOOP TO WORK PROPERLY
		
	print("Floor generated")
	print(str(len(rooms)) + " rooms generated.")
	
	# Now delete all invalid potentials
	for room in rooms:
		room.collapse()
	
func neg(num: int):
	# Returns the negative version of a number.
	if num < 0:
		return num
	return num * -1
