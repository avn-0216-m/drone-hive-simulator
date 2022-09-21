extends StaticBody

onready var col: CollisionShape = get_node("FloorCollision") 
onready var mesh: MeshInstance = get_node("FloorCollision/FloorMesh")
onready var walls: Spatial = get_node("FloorCollision/Walls")
var max_size: Vector3

func set_scale(new_scale: Vector3):
	# Updates physical and UV scale so the tiling textures tile correctly
	# regardless of size.
	mesh.material_override.uv1_scale = new_scale / 2
	col.scale = new_scale
	
func get_edges() -> Array:
	return [Vector3(col.scale.x, 0, 0)]

func _ready():
	randomize()
	set_scale(Vector3(3 + randi() % 10,1,3 + randi() % 10))
	
func show_edges(obj, key):
	print("Showing Edges")
	for edge in get_edges():
		var m = MeshInstance.new()
		m.mesh = CubeMesh.new()
		$EdgeTween.interpolate_property(m, "translation", Vector3(0,0,0), edge, 2)
		add_child(m)
		$EdgeTween.start()
		
