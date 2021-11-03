extends Spatial

func _ready():
	print("ArrayMesh test begin!")
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES) # every 3 verticies is rendered as a tri
	st.add_vertex(Vector3(1,0,0))
	st.add_vertex(Vector3(0,1,0))
	st.add_vertex(Vector3(1,1,0))
	get_node("Mesh").mesh = st.commit()
	
	print("ArrayMesh test end!")

