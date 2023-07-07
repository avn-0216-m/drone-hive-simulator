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
	
		visited.clear()
	
		print("beginning snakery")
	
		var maximum_moves = 100
	
		turtle = world_to_map(from["pos"])
		var target = world_to_map(to["pos"])
		
		
		match to["orientation"]:
				0: # eastern
					to["pos"].x -= sticky_outy
				10: # western
					to["pos"].x += sticky_outy
				16: # southern
					to["pos"].z += sticky_outy
				22: # northern
					to["pos"].z -= sticky_outy
					
		print(to["pos"])
		print(from["pos"])
		
		# the TURTLE uses CELL position, NOT global position!
		# 1 unit of distance = 1 cell moved.
		move(Move.NONE, true)
		
		# start by creating a path in the direction of egress.
		# because it looks nice and is less cramped.
		match from["orientation"]:
			0: # eastern
				direction = Move.EAST
			10: # western
				direction = Move.WEST
			16: # southern
				direction = Move.SOUTH
			22: # northern
				direction = Move.NORTH
		
		for i in range(0,sticky_outy):
			move(direction, true)
				
		var moves = 0
		var stored = []
		
		# some kind of array where you store blocked directions
		# then pop them off as you find alternatives and go back to moving in them??
		var prev_result = 0
		while turtle != to["pos"] and moves < maximum_moves and direction != Move.NONE:
			match prev_result:
				0:
					print("good")
					direction = get_direction(to, turtle)
				1: # blocked
					print("blocked")
					direction = right_turns[direction]
				2: # bonked
					print("bonked")
					direction = reversed[direction]
			prev_result = move(direction)
			moves += 1
				
		# clear your visited tiles when done with your snakery
		visited.clear()
		
func get_direction(to, turtle) -> int:
	
	# if the target door is facing east or west, prioritize getting horizontal
	# if the target door is north or south, prioritize getting vertical
	
	match to["orientation"]:
		0, 10: # east and west
			if turtle.z < to["pos"].z:
				return Move.NORTH
			elif turtle.z > to["pos"].z:
				return Move.SOUTH
			else:
				print("aligned 1")
				if turtle.x < to["pos"].x:
					return Move.EAST
				else:
					return Move.WEST
		16, 22: # north and south
			if turtle.x < to["pos"].x:
				return Move.EAST
			elif turtle.x > to["pos"].x:
				return Move.WEST
			else:
				print("aligned 2")
				if turtle.z < to["pos"].z:
					return Move.SOUTH
				else:
					return Move.NORTH
	return Move.NONE
