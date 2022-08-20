extends InstanceManagerBase
class_name BonusManager

export var bird_factor: int = 3

func generate_active_pool(level_count: int) -> Array:
	
	if len(source_pool) == 0: return []
	active_pool.clear()
	
	if level_count % bird_factor == 0:
		active_pool.append(source_pool[0])
	return active_pool
	
	print("bonus pool generated")
	print(active_pool)
