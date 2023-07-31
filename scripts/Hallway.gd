extends GridMap

var doors = []
var junctions = []
var visited = []
var placeholders: GridMap

export var egress = 3

onready var turtle_src = load("res://objects/Turtle.tscn")

func mark_doors(arr: Array):
		doors.append_array(arr)

func add_hallway():
	# take one door group and dump all other nodes into a separate array
	# this prevents doorways from linking to the same room.
	for door in doors:
		var eligible = []
		for door2 in doors:
			if door.room != door2.room: 
				eligible.append(door2)
		eligible.append_array(junctions)
				
		# now find the closest junction/door to another room.
		var shortest_distance = INF
		var target
		for e in eligible:
			if door.pos.distance_to(e.pos) < shortest_distance:
				shortest_distance = door.pos.distance_to(e.pos)
				target = e
		
		# instance turtles to find the best path to goal.
		var turtle_obj = turtle_src.instance()
		turtle_obj.placeholders = placeholders
		turtle_obj.egress = egress
		turtle_obj.pathfind(door, target)
