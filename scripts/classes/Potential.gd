extends Node

class_name Potential

var room: Node
var orientation: int
	#  0 = west-facing door
	# 10 = east-facing door
	# 16 = south-facing door
	# 22 = north-facing door
var cell: Vector3
var is_doorway: bool
var connection: Potential
