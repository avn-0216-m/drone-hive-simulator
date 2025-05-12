extends Node

var min_walkway_length = 3
var max_walkway_length = 10

var potentials: Array = []

var path_root = "res://objects/levelgen/rooms/"

var start_rooms = [
	"start1.tscn"
	]
	
var rooms = [
	"test1.tscn",
	"test2.tscn",
	"test3.tscn",
	"test4.tscn"
	]

func placehold_room(room: Node):
	var offset = Vector3i(room.position/2)
	offset.y = 0
	for cell in room.foundations.get_used_cells():
		$Placeholders.set_cell_item(cell + offset, 0)

func _ready():
	new_level()

func new_level():
	
	var start = load(path_root + start_rooms[0]).instantiate()
	$Rooms.add_child(start)
	placehold_room(start)
	potentials += start.potentials
	
	while $Rooms.get_child_count() < 10:
		potentials.shuffle()
		var start_potential = potentials.pop_front()
		if start_potential == null:
			return
		var target = 0
		match start_potential.orientation:
			0: target = 10
			10: target = 0
			16: target = 22
			22: target = 16
		
		rooms.shuffle()
		var room = rooms.pick_random()
		# pick door, get potentials, see if any potential orientations align with the start
		# 10 <-> 0
		# 16 <-> 22
		
	
