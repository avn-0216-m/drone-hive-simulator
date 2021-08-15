extends Spatial

onready var floors = get_node("Floor")
onready var walls = get_node("Walls")
onready var intern_corners = get_node("InternalCorners")
onready var extern_corners = get_node("ExternalCorners")

var floor_positions: Array = []

func add_floor(pos: Vector3):
	# changing the instance count resets all instance positions,
	# so append them here and init them in the init func.
	floor_positions.append(pos)
	
func add_wall(pos):
	return
	
func add_intern_corner(pos):
	return
	
func add_extern_corner(pos):
	return

func init_multimeshes():
	floors.multimesh.instance_count = len(floor_positions)
	for i in range(len(floor_positions)):
		floors.multimesh.set_instance_transform(i, Transform(Basis(), floor_positions[i]))
