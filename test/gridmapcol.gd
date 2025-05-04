extends GridMap

func _ready():
	for cell in get_used_cells():
		print(cell)
		print(map_to_local(Vector3i(cell.x, cell.y, cell.z)))
		print("---")
