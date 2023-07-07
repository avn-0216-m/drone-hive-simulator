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
		data["pos"] = to_global(walls.map_to_world(door["cell"].x, door["cell"].y, door["cell"].z))
		data["orientation"] = door["orientation"]
		data["room_name"] = self.name
		doors.append(data)
	return doors
