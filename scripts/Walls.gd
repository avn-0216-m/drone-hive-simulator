extends GridMap

enum Geo { BOX,CORNER,POST,WALL,DOUBLE,CURVE,POTENTIAL}

export var potential_base = 10.0 # chance for a Potential tile to become a door
export var potential_decay = 4.5 # loss of chance per each successful door spawn
var potential = potential_base

signal doorway_added(pos)

var door_src: PackedScene = preload("res://objects/Door.tscn")
var door_obj = null

func _ready():
	for cell in get_used_cells():
		if get_cell_item(cell.x, cell.y, cell.z) == Geo.POTENTIAL:
			randomize()
			var roll = randi() % 10
			if roll < potential: # if the randi rolls less than the potential
				potential = max(0, potential - potential_decay)
				door_obj = door_src.instance()
				door_obj.translation = map_to_world(cell.x, cell.y, cell.z)
				emit_signal("doorway_added", to_global(door_obj.translation))
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
			# Then, replace potential with empty or a wall.
			set_cell_item(cell.x, cell.y, cell.z, 
				-1 if door_obj != null else Geo.WALL, 
				get_cell_item_orientation(cell.x, cell.y, cell.z))
			door_obj = null