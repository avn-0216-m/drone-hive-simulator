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
		Vector3(1,0,0),  # Right
		Vector3(1,0,-1), # Up-Right
		Vector3(-1,0,-1),# Up-left
		Vector3(1,0,1),  # Down-right
		Vector3(-1,0,1)  # Down-left 
	]
	
func explore(step: Step):
	# Explores all neighbors (+ lookahead) of a given Step node, 
	# creates Step nodes for each, calculates costs, and returns an array of 
	# all found nodes.
	
	#print("Exploring: " + str(step.cell))
	
	var found: Array = []
	
	# Move the step from open to closed (unexplored to explored).
	open.erase(step)
	closed.append(step)
	for offset in offsets:
		var new = Step.new(step.cell + offset)
		new.parent = step
		new.calc(start, end)
		if not already_explored(new.cell) and placeholders.get_cell_item(new.cell.x, 0, new.cell.z) == -1:
			found.append(new)
	#print("Found this many new nodes: " + str(len(found)))
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
	
	
	#print("Start: " + str(start))
	#print("End: " + str(end))
	
	start_step = Step.new(start)
	open.append(start_step)
	
	while len(open) < maximum_explored_tiles and len(open) != 0:
		var best_step: Step
		best_step = find_best_step(open, end)
		
		#print("Open steps:")
		#print(open)
				
		if best_step.cell == end:
			#print("WOAWWWWW")
			break

		var found = explore(best_step)
		for step in found:
			add_step(step)
			
	print("Pathfinding complete.")
	debug()
	var end_step = get_step_at(end)
	if end_step:
		#print("End step.")
		var backwards = end_step
		var cells = []
		while backwards != null:
			cells.append(backwards.cell)
			print(backwards.cell)
			backwards = backwards.parent
		return cells
	return []
	
func get_step_at(cell: Vector3):
	for step in open:
		if step.cell == cell:
			return step
	return null
	
func add_step(step: Step):
	# Add new step. 
	# If step already exists but fcost is lower, update the parent to reflect
	# better path.
	open.append(step)
	return
	
func find_best_step(steps: Array, end: Vector3):
	var best_step: Step
	var lowest_cost = 1000000000000
	var lowest_h = 1000000000000
	for step in steps:
		if step.cell == end:
			print("End cell found!")
			return step
		if step.get_f() < lowest_cost:
			best_step = step
			lowest_cost = best_step.get_f()
		elif step.get_f() == lowest_cost and step.h < lowest_h:
			best_step = step
			lowest_cost = best_step.get_f()
			lowest_h = best_step.h
	return best_step
	
func debug():
	for step in open:
		$Debug.set_cell_item(step.cell.x, 0, step.cell.z, 3)
	for step in closed:
		$Debug.set_cell_item(step.cell.x, 0, step.cell.z, 2)
