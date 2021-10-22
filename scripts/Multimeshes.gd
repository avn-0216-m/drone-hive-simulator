extends Spatial

onready var floors = get_node("Floor")
onready var walls = get_node("Walls")
onready var intern_corners = get_node("InternalCorners")
onready var extern_corners = get_node("ExternalCorners")

# changing the instance count resets all instance positions,
# so append them to arrays and init them in the init func.

func init_multimeshes():
	
	var floor_bodies = get_tree().get_root().get_node("Main/Viewport/Game/Level/Geometry/Bodies/Floor").get_children()
	floors.multimesh.instance_count = len(floor_bodies)
	for i in range(len(floor_bodies)):
		floors.multimesh.set_instance_transform(i, floor_bodies[i].get_child(0).get_global_transform())

	var wall_bodies = get_tree().get_root().get_node("Main/Viewport/Game/Level/Geometry/Bodies/Walls").get_children()
	walls.multimesh.instance_count = len(wall_bodies)
	for i in range(len(wall_bodies)):
		walls.multimesh.set_instance_transform(i, wall_bodies[i].get_child(0).get_global_transform())

	var external_bodies = get_tree().get_root().get_node("Main/Viewport/Game/Level/Geometry/Bodies/ExternalCorners").get_children()
	extern_corners.multimesh.instance_count = len(external_bodies)
	for i in range(len(external_bodies)):
		extern_corners.multimesh.set_instance_transform(i, external_bodies[i].get_child(0).get_global_transform())

func reset():
	floors.multimesh.instance_count = 0
	walls.multimesh.instance_count = 0
	extern_corners.multimesh.instance_count = 0
