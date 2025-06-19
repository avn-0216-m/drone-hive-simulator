extends Node3D
class_name Room

@export var unlock_floor: int = 0

@export_enum(
	"Unspecified", "Bedroom", "Kitchen", "Hallway", 
	"Bathroom", "Lounge"
	) var room_type: int
	
@export var potentials: Array = []
@onready var foundations: GridMap = get_node("Foundations")
@onready var decor: GridMap = get_node("Decor")
@onready var drop_map: GridMap = get_node("DropPoints")
@onready var door_src = load("res://objects/door/scifidoor.tscn")
@onready var debug_meshlib = load("res://objects/levelgen/debug.tres")
var drop_points: Dictionary = {}

func update_drop_points():
	# Rather than doing all this global parsing every time a room wants to know
	# its global drop points (which could be multiple times if depth > 0),
	# parse it all in advance, AND return a dict so sprinkler items can
	# erase valid drop points upon consumption to avoid reuse.
	for cell in drop_map.get_used_cells_by_item(3):
		drop_points[to_global(cell * 2) + Vector3(1, 1, 1)] = get_path()

func get_drop_points(depth: int = 0, flood: bool = false, exclude: Array = []) -> Dictionary:
	# Get the drop_points of this room, and of additional connected rooms
	# as specified by the traversal depth.
	var total_drop_points: Dictionary = {}
	total_drop_points.merge(drop_points)
	print(str(depth) + ": " + str(len(total_drop_points)))
	if depth > 0:
		for pot in potentials:
			# TODO: Make this random instead of picking the first applicable.
			if pot.connection != null and pot.connection.room not in exclude:
				total_drop_points.merge(pot.connection.room.get_drop_points(depth - 1, flood, exclude + [self]))
				if not flood:
					break
	return total_drop_points

func get_potentials():
	return potentials

func setup_doors():
	for potential in potentials:
		if potential.is_door:
			foundations.set_cell_item(potential.cell, -1, potential.orientation)
			var door_obj = door_src.instantiate()
			add_child(door_obj)
			door_obj.position = potential.cell * 2
			door_obj.position += Vector3(1,1,1)
			match potential.orientation:
				0: door_obj.rotation_degrees.y = 0 # West
				10: door_obj.rotation_degrees.y = 180 # East
				16: door_obj.rotation_degrees.y = 90 # South
				22: door_obj.rotation_degrees.y = 270 # North
		else:
			foundations.set_cell_item(potential.cell, 4, potential.orientation)

func erase_drop_point(drop_point: Vector3i):
	drop_points.erase(drop_point)
	drop_map.set_cell_item(drop_map.local_to_map(to_local(drop_point)), 2)


func _ready():
	foundations.set_collision_layer_value(2, true)
	
	# get all potentials
	for cell in foundations.get_used_cells_by_item(7):
		var potential = Potential.new()
		potential.room = self
		potential.orientation = foundations.get_cell_item_orientation(cell)
		potential.cell = cell
		potentials.append(potential)

	autofill_drop_map()
	
	# Finally, hide the drop-points.
	drop_map.visible = false
		
func autofill_drop_map():
	# This function is inaccurate and does not account for decor that spans
	# multiple cells (e.g bookcases, desks). You will need to mark those areas
	# manually.
	
	# Create the drop points map if none exists
	if drop_map == null:
		drop_map = GridMap.new()
		drop_map.mesh_library = debug_meshlib
		add_child(drop_map)

	# Then, set all cells to green if the room has no decor.
	if decor == null:
		for cell in foundations.get_used_cells_by_item(2):
			drop_map.set_cell_item(cell, 3)
		return
	
	# Then, only set cells to green if the tile has no decor on it.
	for cell in foundations.get_used_cells_by_item(2):
		if set_if_empty(cell, 3): # Green sphere.
			# If the sphere is successfully set, that means the cell wasn't
			# manually audited in advance, so check for decor above the base cell too.
			# (e.g stuff on desks and bookcases).
			for i in range(0,5):
				if decor.get_cell_item(cell + Vector3i(0,i,0)) != -1:
					drop_map.set_cell_item(cell, 2) # Red sphere.
				
func set_if_empty(cell: Vector3i, item: int):
	if drop_map.get_cell_item(cell) == -1:
		drop_map.set_cell_item(cell, item)
		return true
	return false
