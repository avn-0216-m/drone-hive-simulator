extends Node

class_name Potential

var room: Node # the room the potential belongs to.
var orientation: int
var offset: Vector3
var valid: bool = false # if true, instance into a door, otherwise a wall.
var cell: Vector3 # Local gridmap cell.
var connected: Potential
