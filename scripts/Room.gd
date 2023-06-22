extends GridMap

enum Geo { BOX,CORNER,FLOOR,POST,WALL,DOUBLE,CURVE,POTENTIAL}
enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

export var potential_base = 10.0 # chance for a Potential tile to become a door
export var potential_decay = 0 #4.5 # loss of chance per each successful door spawn
var potential = potential_base

var door_src: PackedScene = preload("res://objects/Door.tscn")
var door_obj = null

func _ready():
	# doorways:
	# find all potential doorways on the map and convert at least one
	# into a normal door.
	# after that, each remaining potential has a chance to become another
	# doorway, with diminishing returns.
	# potentials that do not become doors instead become walls.
	for cell in get_used_cells():
		if cell.y != 1:
			continue
		if get_cell_item(cell.x, cell.y, cell.z) == Geo.POTENTIAL:
			randomize()
			var roll = randi() % 10
			if roll < potential: # if the randi rolls less than the potential
				potential = max(0, potential - potential_decay)
				door_obj = door_src.instance()
				door_obj.translation = map_to_world(cell.x, cell.y, cell.z)
				match get_cell_item_orientation(cell.x, cell.y, cell.z):
					0: # eastern
						door_obj.rotation_degrees.y = 0
					10: # western
						door_obj.rotation_degrees.y = 180
					16: # southern
						door_obj.rotation_degrees.y = 90
					22: # northern
						door_obj.rotation_degrees.y = 270
				add_child(door_obj)
			# Then, always remove the wall.	
			set_cell_item(cell.x, cell.y, cell.z, 
				-1 if door_obj != null else Geo.WALL, 
				get_cell_item_orientation(cell.x, cell.y, cell.z))
			door_obj = null
			
	# furniture:
	# find the gridmap child and look through its furniture
	# instance any necessary gridmap tiles into real objects where necessary.
	# delete the tile and replace it with the real object.
	return
