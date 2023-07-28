extends Spatial

enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

onready var walls = get_node("Geometry/Walls")
onready var floors = get_node("Geometry/Floor")

signal doorway_added(pos)

func _ready():
	var doors = walls.add_doorways()

func get_doors() -> Array:
	var doors = []
	for door in walls.doors:
		var data = {}
		
		# positions given here are converted into global co-ords
		# because rooms aren't all at (0,0,0)
		# you'll need to convert them back to gridmap co-ords as and when you
		# need them.
		# you can use any gridmap to convert to accurate co-ords SO LONG AS
		# it's at 0,0,0.
		# e.g: placeholder, hallway gridmaps.
		
		data["pos"] = to_global(walls.map_to_world(door["cell"].x, door["cell"].y, door["cell"].z))
		data["orientation"] = door["orientation"]
		data["room_name"] = self.name
		doors.append(data)
	return doors
