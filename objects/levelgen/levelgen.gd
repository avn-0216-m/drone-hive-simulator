extends Node

var min_walkway_length = 3
var max_walkway_length = 10

var start_rooms = ["res://objects/levelgen/unique/start/start1.tscn"]

func new_level():
	return
	# what do we wanna do?
	# i wanna have one "new level" script that can be called and generates a new level
	# clear out the existing level
	# add starting room (closet)
	# /loop
	# place room
	# add new room potentials to the list
	# pick a random potential, try adding a room adjacent to it
	# if placement is ok, confirm placement by adding placeholder elements
	
	# note:
	# if rooms_placed + potential >= room limit, safe to start placing terminating rooms (rooms with only 1 entrance/exit)
