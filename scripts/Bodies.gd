extends Node3D

func reset():
	for container in get_children():
		for child in container.get_children():
			child.free()
