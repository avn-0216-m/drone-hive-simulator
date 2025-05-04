extends InstanceManagerBase
class_name BonusManager

@export var bird_factor: int = 3

func generate_active_pool(level_count: int) -> Array:
	
	if len(source_pool) == 0: return []
	active_pool.clear()
	
	if level_count % bird_factor == 0:
		active_pool.append(source_pool[0])
		
	for i in range(0,ceil(objects_per_level * float(level_count))):
		var index = randi() % len(source_pool)
		if index == 0:
			index += 1
		active_pool.append(clone(source_pool[index], source_class))

	return active_pool
