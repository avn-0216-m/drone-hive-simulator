extends Node3D

func _ready():
	get_node("Area3D").connect("area_entered", Callable(self, "entered"))
	get_node("Area3D").connect("area_exited", Callable(self, "exited"))
	
	get_node("Area3D").position = Vector3(999,999,999)
	await get_tree().idle_frame
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area3D").position = Vector3(0,0,0)
	await get_tree().idle_frame
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area3D").position = Vector3(999,999,999)
	await get_tree().idle_frame
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area3D").position = Vector3(0,0,0)
	await get_tree().idle_frame
	#print(get_node("Area").get_overlapping_areas())

func entered(area):
	print(area.name + ": entered")
	
func exited(area):
	print(area.name + ": exited")
