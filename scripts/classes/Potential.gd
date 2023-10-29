extends Node

class_name Potential

var room: Node # the room the potential belongs to.
var orientation: int
var offset: Vector3
var valid: bool = false # if true, instance into a door, otherwise a wall.
var cell: Vector3 # Local gridmap cell.
var connected: Potential

# don't use these stupid fuckin things
var cell_local: Vector3 # local gridmap cell. you probably shouldn't use this.
var cell_global: Vector3 # global gridmap cell.
var pos: Vector3 # global position.
