extends Spatial

var first_step: Step
var start_tile: Vector3
var goal_tile: Vector3

# inherited from Hallway parent object.
var start: Dictionary
var goal: Dictionary
var placeholders: GridMap
var egress: int = 2

func _ready():
	
	# start by converting the start/goal global pos data
	# into gridmap co-ords
	start_tile = placeholders.world_to_map(
		Vector3(start["pos"].x, start["pos"].y, start["pos"].z))
	goal_tile = placeholders.world_to_map(goal["pos"])


	# ensure the goal tile also has egress applied to it
	match goal["orientation"]:
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
	
func get_all_steps():
	var max_tries = 100 # to prevent while-loop locking.
	var tries = 0
	
	var step = first_step
	
	while step.next != null and step.pos != step.next.pos and tries < max_tries:
		tries += 1
		if step.pos.x > step.next.pos.x:
			step.pos.x -= 1
		elif step.pos.x < step.next.pos.x:
			step.pos.x += 1
		
		if step.pos.z > step.next.pos.z:
			step.pos.z -= 1
		elif step.pos.z < step.next.pos.z:
			step.pos.z += 1
	return true

func trundle():
	# path directly to target (should be 3 steps max) by aligning on an axis
	# then going directly towards it.
	# after that, find collisions between steps and nudge them out of the way
	# in order to make a clean non-collision-y path. 
	
	# questions:
	# if start already axis-aligned with goal, should a new node be placed
	# (likely overlapping with prev node?)
	# answer:
	# probably yes, so i can adjust it later, as there's a 50/50 chance of it
	# doubling back on itself in that case. which is obv bad.
	
	#setup first step using egress (so the hallway sticks out from the door)
	if first_step == null:
		first_step = Step.new(start_tile)
		match start["orientation"]:
			0: # eastern
				first_step.next = Step.new(start_tile - Vector3(egress, 0, 0))
			10: # western
				first_step.next = Step.new(start_tile + Vector3(egress, 0, 0))
			16: # southern
				first_step.next = Step.new(start_tile + Vector3(0, 0, egress))
			22: # northern
				first_step.next = Step.new(start_tile - Vector3(0, 0, egress))
		
	# now, align with goal.
	var alignment: Vector3 = Vector3(0,0,0)
	match start["orientation"]:
		0, 10: # align vertically
			alignment = Vector3(goal_tile.x, 0, start_tile.z)
		16, 22: # align horizontally
			alignment = Vector3(start_tile.x, 0, goal_tile.z)
	add_step(alignment)
	
	# go directly to goal
	add_step(goal_tile)
	
	refine_route()
	
	debug()
	
	print("turtle done")
	return get_all_tiles(first_step)
	
func get_all_tiles(start: Step):
	var tiles = []
	var tile_collector = Step.new(start.pos)
	var target = start.next
	while target != null:
		while tile_collector.pos != target.pos:
			tiles.append(tile_collector.pos)
			approach_menacingly(tile_collector, target)
		target = target.next
	return tiles
		
func insert_edge(step: Step):
	# the shadow the hedgehog function, or something.
	# modifies a linked list to insert two step nodes after the specified step
	# the new steps have the same positions as the original and its next step
	
	print("inserting a new edge")
	
	var new_step = Step.new(step.pos)
	var new_step2 = Step.new(step.next.pos)
	
	new_step.next = new_step2
	new_step2.next = step.next
	step.next = new_step
	
	return new_step

func refine_route():
	# goes step by step, nudging paths out of the way of collisions
	# remember: when modifying a step's position, modify the next step's position as well
	# in this way, you are modifying an "edge"........ woag....
	
	# TODO: get collision point information, similar to raycasting
	# insert new step node at (or just before) point of collision
	# then nudge from there
	# it will essentially "shrink wrap" around any collisions
	# and should IDEALLY be able to handle complexities
	
	var max_tries = 100
	var tries = 0
	var nudge_start_pos = Vector3(0,0,0)
	var nudge_next_start_pos = Vector3(0,0,0)
	var nudge_amount = 1
	var nudge_flip = false
	
	print("refining turtle route")
	
	var result = test_full_route()
	while result is Step:
		if result is Step:
			result = insert_edge(result)
			var nudge = Vector3(0,0,0)
			nudge_start_pos = result.pos
			nudge_next_start_pos = result.next.pos
			# determine vector
			# TODO: consider implementing a "flip flop" algorithm that tests
			# both perpendicular nudge directions until a safe route is found
			# would probably result in tidier hallways
			while test_route(result) != true:
				print("applying nudge...")
				
				if result.pos.x != result.next.pos.x:
					result.pos.z = nudge_start_pos.z + abs(nudge_amount) if nudge_flip else nudge_amount
					result.next.pos.z = nudge_next_start_pos.z + abs(nudge_amount) if nudge_flip else nudge_amount
				else:
					result.pos.x = nudge_start_pos.x + abs(nudge_amount) if nudge_flip else nudge_amount
					result.next.pos.x = nudge_next_start_pos.x + abs(nudge_amount) if nudge_flip else nudge_amount
				
				print(nudge_amount)
				
				nudge_amount -= 1
				nudge_flip = !nudge_flip

			print("nudge successful.")
			tries += 1
			if tries > max_tries:
				print("TERMINATED")
				break
		result = test_full_route()
		
	if tries >= 100:
		print("TERMINATED")
	return
	
func test_route(start: Step):
	# tests the route between two steps.
	# returns false if a collision is found. otherwise returns true
	var max_tries = 100 # to prevent while-loop locking.
	var tries = 0
	
	# if it's the last step then there's no possible collision
	if start.next == null:
		return true
	
	# gotta DUPLICATE THAT SHIT when you're PASSING BY REFERENCE FFSSSSSSS
	var step = Step.new(start.pos)
	var target = start.next
	
	while step.pos != target.pos and tries < max_tries:
		tries += 1
		if placeholders.get_cell_item(step.pos.x, 0, step.pos.z) != -1:
			return false
		approach_menacingly(step, target)
	return true
	
	# TODO: needs to return a TurtleCollision object.
	
func approach_menacingly(step: Step, target: Step):
	# moves the current step towards the target by one tile (x or z).
	
	# prioritizing x axis over z axis here SHOULD be fine because
	# steps are supposed to be axis aligned anyway.
	if step.pos.x > target.pos.x:
		step.pos.x -= 1
	elif step.pos.x < target.pos.x:
		step.pos.x += 1
		
	if step.pos.z > target.pos.z:
		step.pos.z -= 1
	elif step.pos.z < target.pos.z:
		step.pos.z += 1
	# modifies the value by ref so no need to return anything
	
func test_full_route():
	# tests whole route, returns a step if a collision is detected there.
	# otherwise returns false
	if first_step == null: # just in case, ye fearsome ducks.
		return true
	
	var step = first_step
	
	while step != null:
		if not test_route(step):
			print("full route has collisions.")
			return step
		step = step.next
	return false
	
func debug():
	# prints all step positions to gridmap for visual clarity.
	var step = first_step
	while step != null:
		#print(name + str(step.pos))
		$Debug.set_cell_item(step.pos.x, step.pos.y, step.pos.z, 1)
		step = step.next
