extends Object
class_name placement_req

var safe: bool = false
var countdown: int = 3
var pos # Vector3 but if I type hint Godot gets shitty about nulls so
var area: Area
var index: int

func _init(given_index):
	index = given_index
	# create nodes
	var area = Area.new()
	area.collision_layer = 16
	area.collision_mask = 16
	var collision = CollisionShape.new()
	var box_shape = BoxShape.new()
	# set collision shape
	collision.shape = box_shape
	# add collision to area
	area.add_child(collision)
	# add area reference to placement
	self.area = area
	# connect signal
