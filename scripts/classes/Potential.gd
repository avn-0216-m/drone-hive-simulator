extends Node

class_name Potential

var room: Node # the room the potential belongs to.
var orientation: int
var cell_local: Vector3 # local gridmap cell. you probably shouldn't use this.
var cell_global: Vector3 # global gridmap cell.
var pos: Vector3 # global position.
var valid: bool = false # if true, instance into a door, otherwise a wall.
