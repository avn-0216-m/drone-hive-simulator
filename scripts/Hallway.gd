extends GridMap

var doors = [] # Array of Door objects, contains position, orientation, and the
# room it belongs to.
var junctions = []
var visited = []
var placeholders: GridMap

export var egress = 2

onready var turtle_src = load("res://objects/Turtle.tscn")

func mark_doors(arr: Array):
		doors.append_array(arr)


