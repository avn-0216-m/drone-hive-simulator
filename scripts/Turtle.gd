extends Spatial

# This is a modified version of A* that only looks in the four cardinal
# directions and has the capability to "look ahead" multiple tiles at once.

# Data recieved from Hallway parent node.
var start_door: Door
var end_door: Door
var egress: int = 3

# GridMap co-ords.
var start: Vector3
var end: Vector3

var start_step: Step
var maximum_explored_tiles: int = 50000

# Arrays of Step nodes, checked and not.
var open: Array
var closed: Array

# Used for collision checking.
var placeholders: GridMap

export var lookahead = 10
var offsets: Array = [
		Vector3(0,0,-1), # Up
		Vector3(0,0,1),  # Down
		Vector3(-1,0,0), # Left
		Vector3(1,0,0)   # Right
	]
	
func explore(step: Step):
	# Explores all neighbors (+ lookahead) of a given Step node, 
	# creates Step nodes for each, calculates costs, and returns an array of 
	# all found nodes.
	
	print("Exploring: " + str(step.cell))
	
	var found: Array = []
	
	# Move the step from open to closed (unexplored to explored).
	open.erase(step)
	closed.append(step)
	for offset in offsets:
		for i in range(1, lookahead):
			var cell = step.cell + (offset * i)
			if (placeholders.get_cell_item(cell.x, cell.y, cell.z) != -1 or already_explored(cell)):
				break
			var new = Step.new(cell)
			new.parent = step
			new.calc(start, end)
			found.append(new)
	print("Found this many new nodes: " + str(len(found)))
	return found
	
func already_explored(cell: Vector3):
	for step in open + closed:
		if cell == step.cell:
			return true
	return false
	

func pathfind(start_door: Door, end_door: Door) -> Array:
	# Returns an array of gridmap co-ords.
	
	# Convert global positions to gridmap co-ordinates.
	start = placeholders.world_to_map(start_door.pos)
	end = placeholders.world_to_map(end_door.pos)
	
	match start_door.orientation:
		0: # eastern
			start.x -= egress 
		10: # western
			start.x += egress 
		16: # southern
			start.z += egress 
		22: # northern
			start.z -= egress
	match end_door.orientation:
		0: # eastern
			end.x -= egress 
		10: # western
			end.x += egress 
		16: # southern
			end.z += egress 
		22: # northern
			end.z -= egress
	
	
	print("Start: " + str(start))
	print("End: " + str(end))
	
	start_step = Step.new(start)
	open += explore(start_step)
	
	while len(open) < maximum_explored_tiles:
		var best_step: Step
		var lowest_cost = 1000000000000
		var lowest_h = 1000000000000
			
#		print("Explored cells:")
#		print(debug2)
		
		
		for step in open:
			if step.cell == end:
				print("Path found.")
				return []
		
		
			if step.get_f() < lowest_cost:
				best_step = step
				lowest_cost = best_step.get_f()
			elif step.get_f() == lowest_cost and step.h < lowest_h:
				best_step = step
				lowest_cost = best_step.get_f()
				lowest_h = best_step.h
				
		if best_step == null:
			print("ERRORRRR")

		open += explore(best_step)
			
	print("Pathfinding complete.")
			
	return []
