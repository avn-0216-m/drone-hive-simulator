extends Spatial
class_name HomeRoom

enum Style { BASIC,KITCHEN,BEDROOM } # defines wall and floor textures.
export(Style) var style = Style.BASIC

onready var walls = get_node("Geometry/Walls")
onready var floors = get_node("Geometry/Floor")

# TODO (24/06/2024):
# I don't want weird semi-hallways between rooms.
# Room WALLS should overlap. So doors connect rooms DIRECTLY.
# Find a way to get a collision of the FLOOR tiles to use for collision comparisons.
# JUST the floor tiles, because, again, we want the walls to overlap.
# ---
# Plan (???):
# Don't render floor tiles via gridmap
# Use multimesh and build collision shapes from it
# GridMap is very private about the multimeshes it uses behind-the-scenes
# One body can have many collision shapes, so make one for every floor tile
# You can delete them later.
# No wait, that fucking sucks because the player will fall through the floor.

# This is gonna be a real headache if I ever add multiple doors with the same orientation.
# (24/06/2024) Yeah, you're tellin' me.
var north: Potential
var south: Potential
var east: Potential
var west: Potential

var doors = []

func _ready():
	get_potentials()
	
func collapse():
	# Replaces invalid potentials with walls, valid potentials with doors.
	for cell in walls.get_used_cells():
		if walls.get_cell_item(cell.x, 0, cell.z) == 6: # 6 = potential
			for pot in [north, south, east, west]:
				if pot == null:
					continue
				if pot.cell == cell:
					if pot.valid:
						walls.set_cell_item(cell.x, 0, cell.z, -1)
					else:
						var ori = walls.get_cell_item_orientation(cell.x, 0, cell.z)
						walls.set_cell_item(cell.x, 0, cell.z, 3, ori)

func get_potentials(skip = null) -> Array:
	# Returns an array of Potential data.
	var potentials = []
	for cell in walls.get_used_cells():
		if walls.get_cell_item(cell.x, 0, cell.z) == 6: # 6 = potential
			if cell == skip:
				continue
			var potential_data = Potential.new()
			potential_data.cell = cell
			potential_data.orientation = walls.get_cell_item_orientation(cell.x, 0, cell.z)
			potential_data.offset = walls.map_to_world(cell.x, 0, cell.z) # distance from local origin
			potential_data.room = self
			
			# Set the potential data so the level gen script can access it
			# and set the validity during level generation.
			match(potential_data.orientation):
				0:
					west = potential_data
				10:
					east = potential_data
				16:
					north = potential_data
				22:
					south = potential_data
			potentials.append(potential_data)
	return potentials

func get_doors() -> Array:
	# deprecated
	var doors = []
	for door in walls.doors:
		# position here is given as a global.
		# position != cell
		# use a gridmap at 0,0,0 to convert global positions to gridmap cell co-ords
		
		var door_data = Door.new()
		
		door_data.pos = to_global(walls.map_to_world(door.cell.x, 0, door.cell.z))
		door_data.room = self
		door_data.orientation = door.orientation
		doors.append(door_data)
	return doors
