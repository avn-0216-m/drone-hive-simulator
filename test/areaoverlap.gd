extends Spatial

func _ready():
	get_node("Area").connect("area_entered", self, "entered")
	get_node("Area").connect("area_exited", self, "exited")
	
	get_node("Area").translation = Vector3(999,999,999)
	yield(get_tree(), "idle_frame")
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area").translation = Vector3(0,0,0)
	yield(get_tree(), "idle_frame")
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area").translation = Vector3(999,999,999)
	yield(get_tree(), "idle_frame")
	#print(get_node("Area").get_overlapping_areas())
	get_node("Area").translation = Vector3(0,0,0)
	yield(get_tree(), "idle_frame")
	#print(get_node("Area").get_overlapping_areas())

func entered(area):
	print(area.name + ": entered")
	
func exited(area):
	print(area.name + ": exited")
