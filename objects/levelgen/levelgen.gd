extends Node

var min_walkway_length = 2
var max_walkway_length = 10

var room_root = "res://objects/levelgen/rooms/"

var start_rooms = [
	"start1.tscn"
	]
	
var rooms = [
	"test1.tscn",
	"test2.tscn",
	"test3.tscn",
	"test4.tscn"
	]
	
@onready var placeholders: GridMap = get_node("Placeholders")

func placehold_room(room: Node):
	var offset = Vector3i(room.position/2)
	offset.y = 0
	for cell in room.foundations.get_used_cells():
		$Placeholders.set_cell_item(cell + offset, 0)
	for cell in room.foundations.get_used_cells_by_item(7):
		placeholders.set_cell_item(cell + offset, 1)
		
func is_space_free(room: Node, potential: Potential):
	for cell in room.foundations.get_used_cells_by_item(2):
		if placeholders.get_cell_item(
			placeholders.local_to_map(
					room.position + Vector3(cell) * 2)
			) == 0:
			print("UHOH!!!")
			return false
	for i in range(min_walkway_length, potential.length, -1):
		if placeholders.get_cell_item(
			placeholders.local_to_map(
				room.position + (Vector3(potential.cell) + 
				get_vector_from_orientation(potential) * 2)
			)) == 0:
			print("OTHER UH OH")
			return false
	return true

func get_vector_from_orientation(potential: Potential):
	match potential.orientation:
		0: return Vector3(-1,0,0)
		10: return Vector3(1,0,0)
		16: return Vector3(0,0,1)
		22: return Vector3(0,0,-1)
		_: return Vector3(0,0,0)

func _process(delta):
	if Input.is_action_just_pressed("debug_levelgen"):
		new_level()
	if Input.is_action_just_released("debug_levelgen"):
		print("yehaw")
		print($Rooms.get_child_count())
		
func cleanup():
	for node in $Rooms.get_children():
		node.queue_free()
	placeholders.clear()

func _ready():
	new_level()

func new_level():
	print("OK BAWS HERE I GO")
	cleanup()
	var potentials: Array = []
	var start = load(room_root + start_rooms[0]).instantiate()
	$Rooms.add_child(start)
	placehold_room(start)
	potentials.append_array(start.potentials)
	
	while $Rooms.get_child_count() < 10 and not potentials.is_empty():
		potentials.shuffle()
		var start_potential = potentials.pop_back()
		if start_potential == null:
			print("boy we OUTTA potentials now!!!")
		var target = 0
		match start_potential.orientation:
			# 10 <-> 0
			# 16 <-> 22
			0: target = 10
			10: target = 0
			16: target = 22
			22: target = 16

		var room = load(room_root + rooms.pick_random()).instantiate()
		$Rooms.add_child(room)
		room.position = start_potential.room.position
		if room.unlock_floor > GLOBAL.floor: continue
		var end_potential = null
		for found_potential in room.get_potentials():
			if found_potential.orientation == target and found_potential.is_door == false and found_potential.room != start_potential.room:
				end_potential = found_potential
		if end_potential == null:
			room.queue_free()
			$Rooms.remove_child(room) 
			room.visible = false
			continue
		var length_vector = get_vector_from_orientation(start_potential)
		start_potential.length = min_walkway_length
		for i in range(start_potential.length, max_walkway_length + 5):
			if is_space_free(room, end_potential):
				start_potential.is_door = true
				end_potential.is_door = true
				start_potential.connection = end_potential
				end_potential.connection = start_potential
				potentials.append_array(room.get_potentials())
				placehold_room(room)
				break
			else:
				start_potential.length += 1
				if start_potential.length > max_walkway_length:
					print("I GIVE UP!!!")
					room.queue_free()
					$Rooms.remove_child(room) 
					room.visible = false
					break
				else:
					end_potential.room.position = \
					start_potential.room.position - \
					abs((end_potential.cell - start_potential.cell) * 2) + \
					get_vector_from_orientation(start_potential) * 6 
						
	print("OKAY GOOD")
	for room in $Rooms.get_children():
		room.setup_doors()
