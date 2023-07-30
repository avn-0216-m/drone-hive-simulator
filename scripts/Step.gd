extends Node
class_name Step

var pos: Vector3
var next # can't set the type as Step here because Godot gets fussy about
		 # cyclical shit but that's the type.

func _init(pos := Vector3(0,0,0)):
	self.pos = pos
