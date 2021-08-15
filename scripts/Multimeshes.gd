extends Spatial

onready var floors = get_node("Floor")
onready var walls = get_node("Walls")
onready var intern_corners = get_node("InternalCorners")
onready var extern_corners = get_node("ExternalCorners")

var floor_translations: Array = []
var wall_translations: Array = []

# changing the instance count resets all instance positions,
# so append them to arrays and init them in the init func.

func init_multimeshes():
	
	# get the positions of all relevant bodies and give their transform to a mesh.
	
	var floor_bodies = get_tree().get_nodes_in_group("Floor")
	floors.multimesh.instance_count = len(floor_bodies)
	for i in range(len(floor_bodies)):
		floors.multimesh.set_instance_transform(i, floor_bodies[i].get_global_transform())

	var wall_bodies = get_tree().get_nodes_in_group("Straight Wall")
	walls.multimesh.instance_count = len(wall_bodies)
	for i in range(len(wall_bodies)):
		walls.multimesh.set_instance_transform(i, wall_bodies[i].get_global_transform())
