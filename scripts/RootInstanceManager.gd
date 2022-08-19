extends Node

onready var tasks = get_node("TaskManager")
onready var bonus = get_node("BonusManager")
onready var obstacles = get_node("ObstacleManager")

func generate_all_active_pools(level_count):
	for child in get_children():
		child.generate_active_pool()
