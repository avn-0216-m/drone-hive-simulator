extends Node
class_name Step

var cell: Vector3 # GridMap co-ords.
var g: float = 0 # Distance to start.
var h: float = 0 # Distance to end.
var parent: Step

func get_f() -> float:
	return g + h

func calc(start: Vector3, end: Vector3):
	g = cell.distance_to(start)
	h = cell.distance_to(end)

func _init(cell: Vector3):
	self.cell = cell
