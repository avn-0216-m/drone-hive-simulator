extends Node

onready var tasks: Node = get_node("TaskManager")
onready var bonus: Node = get_node("BonusManager")
onready var obstacles: Node = get_node("ObstacleManager")

onready var managers: Array = get_children()

func generate_all_active_pools(level_count):
	for child in get_children():
		child.generate_active_pool(level_count)
