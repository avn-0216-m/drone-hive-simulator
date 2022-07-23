extends Spatial

onready var floor_collision = load("res://objects/collision/Floor.tscn")
onready var c_floor = get_node("Bodies/Floor")
onready var mm_floor = get_node("Multimeshes/Floor")

onready var wall_collision = load("res://objects/collision/Wall.tscn")
onready var c_walls = get_node("Bodies/Walls")
onready var mm_walls = get_node("Multimeshes/Walls")

onready var post_collision = load("res://objects/collision/Post.tscn")
onready var c_post = get_node("Bodies/Posts")
onready var mm_post = get_node("Multimeshes/Posts")

onready var associations = {
	c_floor: mm_floor,
	c_walls: mm_walls,
	c_post: mm_post
}

export(GDScript) var MeshLib
export(GDScript) var Orientation

func add_collider(pos: Vector3, type: int, rot: int):
	
	var inst = null
	var inst_parent = null
	var inst_rotation: Vector3 = Vector3(0,0,0)
	
	match(type):
		MeshLib.Data.FLOOR:
			inst = floor_collision.instance()
			inst_parent = c_floor
		MeshLib.Data.WALL:
			inst = wall_collision.instance()
			inst_parent = c_walls
			match(rot):
				Orientation.Wall.NORTH:
					inst_rotation = Vector3(0,90,0)
				Orientation.Wall.SOUTH:
					inst_rotation = Vector3(0,-90,0)
				Orientation.Wall.EAST:
					inst_rotation = Vector3(0,0,0)
				Orientation.Wall.WEST:
					inst_rotation = Vector3(0,180,0)
		MeshLib.Data.POST:
			inst = post_collision.instance()
			inst_parent = c_post
		_:
			return
		
	
	inst.translation = pos
	inst.rotation_degrees = inst_rotation
	inst_parent.add_child(inst)
	
func get_wall_materials() -> Array:
	var materials: Array = []
	for child in get_node("Multimeshes").get_children():
		if child.multimesh.mesh.surface_get_material(0) is ShaderMaterial:
			materials.append(child.multimesh.mesh.surface_get_material(0))
	return materials
	
func init_multimeshes():
	for c in associations:
		var mm = associations[c]
		mm.multimesh.instance_count = c.get_child_count()
		for i in range(c_floor.get_child_count() - 1):
			if c.get_child(i) == null:
				continue
			mm.multimesh.set_instance_transform(i, c.get_child(i).get_child(0).get_global_transform())
		
