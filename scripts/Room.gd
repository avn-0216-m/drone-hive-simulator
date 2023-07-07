extends Spatial

enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

onready var walls = get_node("Geometry/Walls")
onready var floors = get_node("Geometry/Floor")

signal doorway_added(pos)

func _ready():
	var doors = walls.add_doorways()

func get_door_positions():
	var doors = []
	for door in walls.doors:
		doors.append(to_global(walls.map_to_world(door.x, door.y, door.z)))
	return doors
