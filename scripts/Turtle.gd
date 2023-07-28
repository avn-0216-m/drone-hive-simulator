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
	
	var test_result = test_route()
	if test_route() is Step:
		print("Collision found on route. :(")
		print(test_result)
		print(test_result.pos)
	else:
		print("No collisions found! :)")
	
	debug()
	return first_step
	
func test_route():
	# tests whole route, returns a step if a collision is detected there.
	# otherwise returns true
	
	var max_tries = 100
	var tries = 0
	
	var current_step = first_step
	var current_tile = current_step.pos
	while current_step.next != null:
		while current_tile != current_step.next.pos and tries < max_tries:
			tries += 1
			if placeholders.get_cell_item(current_tile.x, 0, current_tile.z) != -1:
				print(placeholders.get_cell_item(current_tile.x, 0, current_tile.z))
				return current_step
			if current_tile.x > current_step.next.pos.x:
				current_tile.x -= 1
			elif current_tile.x < current_step.next.pos.x:
				current_tile.x += 1
			
			if current_tile.z > current_step.next.pos.z:
				current_tile.z -= 1
			elif current_tile.z < current_step.next.pos.z:
				current_tile.z += 1
		current_step = current_step.next
	
	return null
	
func debug():
	# prints all step positions to gridmap for visual clarity.
	var step = first_step
	while step != null:
		#print(name + str(step.pos))
		$Debug.set_cell_item(step.pos.x, step.pos.y, step.pos.z, 1)
		step = step.next
