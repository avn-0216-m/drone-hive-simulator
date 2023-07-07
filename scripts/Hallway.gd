extends GridMap

var doors = []
var junctions = []
var visited = []
var placeholders: Node

export var sticky_outy = 2

var turtle = Vector3(0,0,0)
var direction = Move.NONE #stores direction turtle is moving in
var right_turns = { # directions to go if blocked.
	Move.NONE: Move.NONE,
	Move.NORTH: Move.EAST,
	Move.SOUTH: Move.WEST,
	Move.EAST: Move.SOUTH,
	Move.WEST: Move.NORTH
}

var reversed = {
	Move.NONE: Move.NONE,
	Move.NORTH: Move.SOUTH,
	Move.SOUTH: Move.NORTH,
	Move.EAST: Move.WEST,
	Move.WEST: Move.EAST
}

var vectors = [
	Vector3(0,0,0),
	Vector3(0,0,-1), #N
	Vector3(0,0,1), #S
	Vector3(1,0,0), #E
	Vector3(-1,0,0) #W
]

enum Move {NONE, NORTH, SOUTH, EAST, WEST}

func mark_doors(arr: Array):
		doors.append_array(arr)
	
func move(dir: int, force = false) -> int:
	var next = turtle + vectors[dir]
	print(next)
	if placeholders.get_cell_item(next.x, 0, next.z) != -1 and !force:
		print("block")
		return 1
#	if visited.has(next) and !force:
#		print("bonk")
#		return 2
		
	turtle = next
	visited.append(turtle)
	set_cell_item(turtle.x, 0, turtle.z, 0)
	direction = dir
	return 0

func add_hallway():
	# take one door group and dump all other nodes into a separate array
	# this prevents doorways from linking to the same room.
	for door in doors:
		var eligible = []
		for door2 in doors:
			if door["room_name"] != door2["room_name"]: 
				eligible.append(door2)
		eligible.append_array(junctions)
				
		# now find the closest junction/door to another room.
		var shortest_distance = INF
		var target
		for e in eligible:
			if door["pos"].distance_to(e["pos"]) < shortest_distance:
				shortest_distance = door["pos"].distance_to(e["pos"])
				target = e
		# path to the target. mark any turns as supplementary junctions.
		
		snake_to(target, door)

func snake_to(to, from):
	
		# when in doubt, it's probably because you're passing by reference.
		to = to.duplicate(true)
		from = from.duplicate(true)
		
		# fuck all this noise
		# dont do this one tile at a time
		# draw nodes representing corners
		# pair them up to make edges
		# adjust edges as necessary to avoid colliding with shit
		# also makes it a lot easier to find junctions
		# you got this
