extends Node

var min_walkway_length = 4
var max_walkway_length = 10

# If total potentials are lower than this value,
# switch to spawning delicious high-nutrient hallways.
@export var threshold: int = 5 

var start_rooms = [
	"start1.tscn"
	]

var room_root = "res://objects/levelgen/rooms/"
var room_pool = [
	"Bathroom1.tscn",
	"Bedroom1.tscn",
	"Bedroom2.tscn",
	"test1.tscn",
	"test2.tscn",
	"FlowerRoom.tscn",
	"ThingieBopRoom.tscn"
	]
	
var hallway_root = "res://objects/levelgen/hallways/"
var hallway_pool = [
	"HallwayEhl.tscn",
	"HallwayHogWild.tscn",
	"HallwayHoooooooori.tscn",
	"HallwayHori.tscn",
	"HallwaySnowflake.tscn",
	"HallwayTee.tscn",
	"HallwayVerti.tscn",
	"HallwayYew.tscn"
]

# Dictionary of every decor item that can be spawned as a real object
# Key = Corresponding meshlib ID
# Value = Path to object
var spawnables = {
	21: "res://objects/flower/Flower.tscn",
	22: "res://objects/thingy_bop/thingy_bop.tscn"
}

# Grabbing child nodes as variables
@onready var rooms: Node3D = get_node("Rooms")
@onready var objects: Node3D = get_node("Objects")
@onready var walkways: GridMap = get_node("Walkways")
@onready var placeholders: GridMap = get_node("Placeholders")

func set_walkways():
	for cell in placeholders.get_used_cells_by_item(1):
		$Walkways.set_cell_item(cell, 0, placeholders.get_cell_item_orientation(cell))

func track_tasks():
	var found_tasks = []
	for object in objects.get_children():
		if object.task != null:
			object.task_complete.connect(GLOBAL.task_completed)
			found_tasks.append(object.task)
	GLOBAL.incomplete_tasks = found_tasks
	GLOBAL.task_goal = int(len(found_tasks) * 0.6)

func spawn_objects(rooms):
	# Iterates over all instanced rooms, and replaces meshlibrary cells
	# with real objects where possible.
	
	# TODO: Instead of using rays to not spawn sprinkler objects in the void,
	# give the parent object a flat array of global positions of the placeholders
	# in the current room and 3 (or so) random adjacent rooms?
	# creates a "trail" of task objects leading to the source if it works right.
	# TODO: placehold_room returns array of global_pos points, assigned to parent room obj
	# for distribution, that the sprinkler function picks randomly from
	# TODO: tweak placeholder code so that furniture like beds or tables are marked as
	# applicable drop-points.
	# TODO: give rooms a "connected_to"/"connections" variable, high-level version 
	# of potential.connection (or just use that since rooms can already access it).
	# (recursive function for drop_point gathering?)
	# TODO: add VERY MINOR jitter to sprinkler obj placement for slight variance
	# not too much or they risk voiding. maybe don't do it if it's near a wall?
	# but I have no idea how I'd do that.
	# TODO: WAIT. i dont have to do any of that placeholder stuff. rooms already
	# have access to their own gridmaps and can just parse it to global pos. DUH.
	# still need the connections to other rooms tho. anyways.
	
	for room: Room in rooms:
		if not room.has_node("Decor"): continue
		for key in spawnables.keys():
			for cell in room.decor.get_used_cells_by_item(key):
				var obj = load(spawnables[key]).instantiate()
				obj.position = room.position + Vector3(cell * 2)
				obj.position += Vector3(1, 3, 1)
				objects.add_child(obj)
				if obj.sprinkler_source != null:
					# Gather drop points for sprinkled items here.
					obj.sprinkle_objects(room.get_floor_cells_global_pos(1))
				room.decor.set_cell_item(cell, -1)

func placehold_room(room: Node):
	var offset = Vector3i(room.position/2)
	offset.y = 0
	for cell in room.foundations.get_used_cells():
		placeholders.set_cell_item(cell + offset, 0)
	for potential in room.get_potentials():
		placeholders.set_cell_item(placeholders.local_to_map(potential.get_global_pos()),1,potential.orientation)
		
	# Put placeholders in the walkway path.
	for potential in room.get_potentials():
		if potential.is_door:
			var base_pos = potential.room.position + Vector3(potential.cell) * 2
			for i in range(0, potential.length):
				var offset_pos = base_pos + get_potential_vector(potential) * 2 * i
				if placeholders.get_cell_item(placeholders.local_to_map(offset_pos)) == -1:
					placeholders.set_cell_item(placeholders.local_to_map(offset_pos), 1, potential.orientation)
		
func is_space_free(room: Node):
	for cell in room.foundations.get_used_cells_by_item(2):
		if placeholders.get_cell_item(
			placeholders.local_to_map(
					room.position + Vector3(cell) * 2)
			) == 0:
			return false
	return true
	
func trim_stray_placeholders(rooms: Array):
	# Doorway placeholders are placed on every "potential" tile, even if they
	# don't become a door in the end. This function replaces all "doorway"
	# placeholders with regular placeholders if the associated tile is a wall.
	for room in rooms:
		for potential in room.get_potentials():
			if not potential.is_door:
				placeholders.set_cell_item(
					placeholders.local_to_map(
						potential.get_global_pos()
					), 0
				)
	
func is_walkway_free(e_pot: Potential):
	# Checks if the walkway would overlap with a room by calculating each
	# step in the path from one room to the next and checking if there's
	# a placeholder tile here.
	# This is so you don't accidentally place a room without a clear path
	# to connect to it.
	var base_pos = e_pot.get_global_pos()
	for i in range(0, e_pot.length):
		if placeholders.get_cell_item(
			placeholders.local_to_map(
				base_pos + get_potential_vector(e_pot) * 2 * i
			)
		) == 0:
			return false
	return true

func get_potential_vector(potential: Potential):
	# Returns the direction that the potential is facing in, as a vector3.
	match potential.orientation:
		0: return Vector3(-1,0,0)
		10: return Vector3(1,0,0)
		16: return Vector3(0,0,1)
		22: return Vector3(0,0,-1)
		_: return Vector3(0,0,0)

func _process(_delta):
	if Input.is_action_just_pressed("debug_levelgen"):
		new_level()
		
func cleanup():
	for node in rooms.get_children():
		node.free()
	for node in objects.get_children():
		node.free()
	GLOBAL.completed_tasks = []
	GLOBAL.incomplete_tasks = []
	placeholders.clear()
	walkways.clear()

func add_object(item: Interactable):
	objects.add_child(item)

func _ready():
	#get_node("Player").inventory.item_dropped.connect(add_object)
	new_level()



func new_level():
	print("OK BAWS HERE I GO")
	cleanup()
	
	# instanced_rooms is used instead of $Rooms.get_child_count() because 
	# queue_free(), of course, does not instantly delete a node. 
	# Since this all runs in one frame, the
	# $Rooms node is inaccurate until the next frame.
	var instanced_rooms: Array = []
	var instanced_hallways: Array = []
	var potentials: Array = []

	var start = load(room_root + start_rooms[0]).instantiate()
	rooms.add_child(start)
	placehold_room(start)
	potentials.append_array(start.potentials)
	instanced_rooms.append(start)
	
	while len(instanced_rooms) < 30 and not potentials.is_empty():
		potentials.shuffle() #TODO: ID-based RNG.
		
		var is_hallway: bool = false

		# Don't pop the potential incase the room gets scrapped and we gotta
		# rerun the loop. Otherwise, it'd be abandoned despite potentially (haha)
		# being usable.
		# Just get it and erase it from the array upon successful placement.
		# Badabing badaboom.
		var start_potential = potentials.front()
		if start_potential == null:
			print("boy we OUTTA potentials now!!!")
			continue
		
		# Understand a given potentials orientation, and find what opposing
		# potential is required to match it (e.g east can only connect to west
		# and not south)
		var target = 0
		match start_potential.orientation:
			# 10 <-> 0
			# 16 <-> 22
			0: target = 10
			10: target = 0
			16: target = 22
			22: target = 16

		# If potential < threshold, spawn a hallway instead of a normal room.
		# (Lots of potentials, does not count against room total.)
		var room = null
		if len(potentials) < threshold:
			room = load(hallway_root + hallway_pool.pick_random()).instantiate()
			is_hallway = true
		else:
			room = load(room_root + room_pool.pick_random()).instantiate() #TODO: ID-based RNG.
		if room == null: continue
		rooms.add_child(room)
		room.position = start_potential.room.position
		
		# Don't use a room if it isn't supposed to spawn yet.
		if room.unlock_floor > GLOBAL.floor: 
			room.queue_free()
			continue
		
		# See if any of the "end/to" potentials in a randomly chosen room match
		# what is required by the "start/from" potential. And don't try to use
		# a potential that is already in use (is_door) or is part of the same
		# room as the start potential.
		var end_potential = null
		for found_potential in room.get_potentials():
			if found_potential.orientation == target and found_potential.is_door == false and found_potential.room != start_potential.room:
				end_potential = found_potential
		if end_potential == null:
			room.queue_free()
			continue
		
		# This for loop is so that rooms can still be placed if rooms would
		# cease to overlap provided the room is a sufficient distance away
		# e.g, with a walkway snaking between a small gap formed by two other
		# rooms.
		# It's a very minor effect that I don't imagine will come up in standard
		# gameplay, but it's important to me. :)
		for i in range(min_walkway_length, max_walkway_length + 1):
			start_potential.length = i
			end_potential.length = i 
			
			# This algebra is high-school level shit but I still had to enter my
			# sherlock mind palace while tripping on a ghoulish edible to even begin
			# to figure it out.
			# I keep trying to explain the formula but it's so blisteringly simple
			# that my explanation is just writing the formula in plain english.
			# So if you're coming back to this in a year trying to understand it,
			# and for some reason cannot, then I pity you.
			end_potential.room.position = start_potential.room.position - Vector3(end_potential.cell - start_potential.cell) * 2
			
			# Offset the end room in the direction of the start room's door,
			# Depending on potential.length (i).
			end_potential.room.position += get_potential_vector(start_potential) * start_potential.length * 2
			
			if not is_walkway_free(end_potential):
				# If this fails, then no amount of offsetting will make the room
				# accessible, so just scrap it now.
				end_potential.room.queue_free()
				break
			if is_space_free(room):
				# Commit the room now that it's found a proper place.
				start_potential.is_door = true
				end_potential.is_door = true
				start_potential.connection = end_potential
				end_potential.connection = start_potential
				placehold_room(end_potential.room)
				potentials.append_array(end_potential.room.get_potentials())
				if is_hallway:
					instanced_hallways.append(end_potential.room)
				else:
					instanced_rooms.append(end_potential.room)
				
				break
		if not end_potential.is_door:
			# Delete the room if it still has not found a good spot, despite
			# the walkway being clear.
			end_potential.room.queue_free()
			potentials.erase(start_potential)

	# Iterate over all instanced rooms, and turn any valid potentials into door objects
	# or walls, if invalid.
	
	var instanced_combined = instanced_rooms + instanced_hallways
	
	for room in instanced_combined:
		room.setup_doors()
	
	trim_stray_placeholders(instanced_combined)
	spawn_objects(instanced_combined)
	set_walkways()
	track_tasks()
	
	print("Total instanced: " + str(len(instanced_combined)))
	print("Rooms instanced: " + str(len(instanced_rooms)))
	print("Hallways instanced: " + str(len(instanced_hallways)))
