extends MeshInstance

export var minimum_room_size: int = 6

# no bump
# 3-------2
# |       |
# 0-------1
# example
# (0,0,0)
# (-2,0,0)
# (-2,0,-2)
# (0,0,-2)

# bump
#     3---2
#     |   |
#	  0---1
# 3-------2
# |       |
# 0-------1
# bump1 == orig2 so they overlap

func create_surface_data(from: Vector2, to: Vector2) -> Array:
	var surface: Array = []
	surface.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices = PoolVector3Array()
	vertices.push_back(Vector3(from.x, 0, from.y))
	vertices.push_back(Vector3(to.x, 0, from.y))
	vertices.push_back(Vector3(to.x, 0, to.y))
	vertices.push_back(Vector3(from.x, 0, to.y))
	
	var uvs = PoolVector2Array()
	uvs.push_back(Vector2(0,0))
	uvs.push_back(Vector2(1,0))
	uvs.push_back(Vector2(1,1))
	uvs.push_back(Vector2(0,1))
	
	surface[ArrayMesh.ARRAY_VERTEX] = vertices
	surface[ArrayMesh.ARRAY_TEX_UV] = uvs
	
	return surface
	
func generate_new_mesh():
	randomize()
	var room_size = Vector2(2 * randi() % 6 + minimum_room_size, 2 * randi() % 6 + minimum_room_size)
	mesh.clear_surfaces()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLE_FAN, create_surface_data(Vector2(0,0), room_size))
	create_multiple_convex_collisions()



