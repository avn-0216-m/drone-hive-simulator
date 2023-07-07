extends GridMap

var door_groups = []
var junctions = []

func mark_doors(arr: Array):
		door_groups.append(arr)

func add_hallway():
	# take one door group and dump all other nodes into a separate array
	# this prevents doorways from linking to the same room.
	for group in door_groups:
		print(group)
		var eligible = []
		# node dump
		for group2 in door_groups:
			if group != group2:
				eligible.append_array(group2)
		eligible.append_array(junctions)
				
		# now find the closest junction/door to another room.
		for door_pos in group:
			var shortest_distance = INF
			var target = Vector3(0,0,0)
			for e in eligible:
				if door_pos.distance_to(e) < shortest_distance:
					shortest_distance = door_pos.distance_to(e)
					target = e
			print("position:")
			print(door_pos)
			print("closest:")
			print(target)
			print("distance:")
			print(shortest_distance)
	
	
	return
