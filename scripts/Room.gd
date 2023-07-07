extends Spatial

enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

onready var walls = get_node("Geometry/Walls")
onready var floors = get_node("Geometry/Floor")
