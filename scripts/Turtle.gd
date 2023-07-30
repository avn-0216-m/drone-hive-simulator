extends Spatial

var first_step: Step
var start_tile: Vector3
var goal_tile: Vector3

# inherited from Hallway parent object.
var start: Door
var goal: Door
var placeholders: GridMap
var egress: int = 2

export var max_tries = 100 

func _ready():
	
	# start by converting the start/goal global pos data
	# into gridmap co-ords
	start_tile = placeholders.world_to_map(
		Vector3(start.pos.x, 0, start.pos.z))
	goal_tile = placeholders.world_to_map(goal.pos)


	# ensure the goal tile also has egress applied to it
	match goal.orientation:
		0: # eastern
			goal_tile.x -= egress 
		10: # western
			goal_tile.x += egress 
		16: # southern
			goal_tile.z += egress 
		22: # northern
			goal_tile.z -= egress

func add_step(pos: Vector3):
	# DON'T FEED REAL CO-ORDS INTO THIS YOU FUCK
	# GRIDMAP CO-ORDS ONLY
	# OR ELSE YOURE IN FOR A WORLD OF PAIN
	# traverse the linked list til you find a step without a next step.
	# set that value to point to the newest step.
	var new_step = Step.new(pos)
		
	var traversed = first_step
	while traversed.next != null:
		traversed = traversed.next
	traversed.next = Step.new(pos)

func trundle():
	# 0) Set first step (same position as door).
	# 1) Move outwards in the direction of the door.
	# 2) Path directly to target (1-2 nodes maximum)
	# 3) Refine the route (placing new nodes and creating diversions by nudging
	# the path off of collisions with rooms) - refine_route()
	
	#setup first step using egress (so the hallway sticks out from the door)
	if first_step == null:
		match start.orientation:
			0: # East
				first_step = Step.new(start_tile - Vector3(egress, 0, 0))
			10: # West
				first_step = Step.new(start_tile + Vector3(egress, 0, 0))
			16: # South
				first_step = Step.new(start_tile + Vector3(0, 0, egress))
			22: # North
				first_step = Step.new(start_tile - Vector3(0, 0, egress))
		
	# Align with goal either:
	match start.orientation:
		0, 10: # Vertically,
			add_step(Vector3(goal_tile.x, 0, start_tile.z))
		16, 22: # Or horizontally.
			add_step(Vector3(start_tile.x, 0, goal_tile.z))
	
	# Go directly to goal, do not collect $200.
	add_step(goal_tile)
	
	refine_route()
	
	debug()
	return get_all_tiles(first_step)
	
func get_all_tiles(start: Step) -> Array:
	var tiles = []
	var tile_collector = Step.new(start.pos)
	var target = start.next
	while target != null:
		while tile_collector.pos != target.pos:
			tiles.append(tile_collector.pos)
			approach_menacingly(tile_collector, target)
		target = target.next
	return tiles
	
		
func insert_edge(at: Step):
	# Inserts two step nodes, forming an edge, into the linked list after the
	# provided node.
	# The new nodes have the same position as the provided node and it's next
	# step.
	
	var new_step = Step.new(at.pos)
	var new_step2 = Step.new(at.next.pos)
	
	new_step.next = new_step2
	new_step2.next = at.next
	at.next = new_step
	
	return new_step
	
func get_path_length():
	var points = []
	var step = first_step
	var count = 0
	while step.next != null:
		points.append(step.pos)
		count += 1
		step = step.next
	print("Length: " + str(count))
	print(points)
	return count

func refine_route():
	var result = TestResult.new(first_step)
	result.successful = false
	while result.successful != true:
		result = test_full_route()
		if result.successful == true:
			print("Successful route found.")
		else:
			poking_stick(insert_edge(insert_step(result.step, result.collision)))

func poking_stick(step: Step):
	var original_pos = step.pos
	var next_original_pos = step.next.pos
	var flip = false
	var nudge_amount = 1
	var nudging_horizontally = (step.pos.x == step.next.pos.x)
	# TODO: I think the pathfinding is getting stuck forever in a 1x1 space
	# because it reverses back into the doorway from its egress point
	# need to figure that out.
	# idea:
	# ignore starting from the door, start from the egress point
	# THEN start from the door in the get_tiles func so the hallway properly connects
	# to the room.
	# and get rid of the function that clears placeholders in the way of doorways
	# also, maybe add a special case in the test route func that checks if 3
	# surrounding tiles (forwards, left and right) are all blocked, so i can reverse
	# nodes backwards as needed.
	
	print("Iterating on:")
	print("Pos1: " + str(original_pos))
	print("Pos2: " + str(next_original_pos))
	print("Now testing:")
	print("Pos1: " + str(step.pos))
	print("Pos2: " + str(step.next.pos))
	
	# Test and nudge until a successful route is found.
	while test_route(step).successful != true:
		if nudging_horizontally:
			step.pos.x = original_pos.x + nudge_amount if flip else nudge_amount * -1
			step.next.pos.x = next_original_pos.x + nudge_amount if flip else nudge_amount * -1
		else:
			step.pos.z = original_pos.z + nudge_amount if flip else nudge_amount * -1
			step.next.pos.z = next_original_pos.z + nudge_amount if flip else nudge_amount * -1
		if flip:
			flip = false
			nudge_amount += 1
		else:
			flip = true
		

		
	print("SUCCESSFUL PARTIAL ROUTE")
	print("lookie")
	print(test_route(step).successful)

func insert_step(after: Step, position: Vector3) -> Step:
	var new = Step.new(position)
	new.next = after.next
	after.next = new
	return new
	
func test_route(start: Step) -> TestResult:
	var result = TestResult.new(start)
	
	print("TESTING: " + str(start.pos))
	
	var last_checked_tile = result.step.pos
	
	if result.next == null:
		print("returning early")
		return result
		
	var step = Step.new(start.pos)
	
	while step.pos != result.next.pos:
		if placeholders.get_cell_item(step.pos.x, 0, step.pos.z) != -1:
			result.collision = last_checked_tile
			result.successful = false
			print("Collision found at: " + str(result.collision))
			return result
		last_checked_tile = step.pos
		approach_menacingly(step, result.next)
	return result
	
func approach_menacingly(step: Step, target: Step):
	# WARNING: This machine does not know the difference between val and ref
	# nor does it care.
	
	# moves the current step towards the target by one tile (x or z).
	# prioritizing x axis over z axis here SHOULD be fine because
	if step.pos.x > target.pos.x:
		step.pos.x -= 1
	elif step.pos.x < target.pos.x:
		step.pos.x += 1
		
	if step.pos.z > target.pos.z:
		step.pos.z -= 1
	elif step.pos.z < target.pos.z:
		step.pos.z += 1
	# modifies the value by ref so no need to return anything
	
func test_full_route() -> TestResult:
	
	print("TESTING FULL ROUTE")
	get_path_length()
	
	var step = first_step
	while step.next != null:
		var result = test_route(step)
		if result.successful == false:
			print("Full route invalid.")
			return result
		else:
			step = step.next
	return TestResult.new()
	
func debug():
	# prints all step positions to gridmap for visual clarity.
	var step = first_step
	while step != null:
		#print(name + str(step.pos))
		$Debug.set_cell_item(step.pos.x, step.pos.y, step.pos.z, 1)
		step = step.next
