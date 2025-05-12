extends Node

class_name Potential

var room: Node
var orientation: int
	#  0 = west-facing door
	# 10 = east-facing door
	# 16 = south-facing door
	# 22 = north-facing door
var length: int # count of cells to linked potential
var cell: Vector3 # position on room gridmap
var is_door: bool = false # whether or not it's a door or a wall
var connection: Potential
