extends Node

class_name Door

var pos: Vector3 # global space position (NOT gridmap co-ords).
var room: Node # the room the doorway belongs to.
var orientation: int
var cell: Vector3 # local gridmap cell. you probably shouldn't use this.
var generate: bool = false # if true, instance into a door, otherwise a wall.
