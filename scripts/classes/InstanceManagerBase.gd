extends Node
class_name InstanceManagerBase

export var source_class: GDScript
export var source_data: GDScript
var source_placeholder: GDScript = load("res://scripts/classes/Placeholder.gd")
export var objects_per_level: int = 1 # Amount of objects added to active pool for current level.
var source_pool: Array = [] # Represents unique list of all possible instancable objects.
var active_pool: Array = [] # Contains objects chosen to be instanced for a given level.

func _ready():
	if source_data != null:
		source_pool = load_source_data()
	print("source data loaded")
	print(source_pool)

func clone(orig: Node, cls: GDScript) -> Node:
	var clone = cls.new()
	for property in orig.get_script().get_script_property_list():
		clone[property.name] = orig[property.name] if property.name != "placeholders" else clone_placeholders(orig[property.name])
	return clone

func generate_active_pool(level_count: int) -> Array:
	
	if len(source_pool) == 0: return []
	
	active_pool.clear()
	for i in range(0,objects_per_level * level_count):
		active_pool.append(clone(source_pool[randi() % len(source_pool)], source_class))
	return active_pool

func load_source_data() -> Array:
	var loaded = []
	var source_data_inst = source_data.new()
	
	for data in source_data_inst.data:
		var new = source_class.new()
		for key in data.keys():
			new[key] = data[key] if key != "placeholders" else load_placeholders(data[key])
		loaded.append(new)
	
	return loaded

func load_placeholders(arr) -> Array:
	var new: Placeholder = source_placeholder.new()
	var placeholders: Array = []
	
	for placeholder in arr:
		for key in placeholder.keys():
			new[key] = placeholder[key]
		placeholders.append(new)
	
	return placeholders
	
func clone_placeholders(arr) -> Array:
	var new: Placeholder = source_placeholder.new()
	var placeholders: Array = []
	
	for placeholder in arr:
		for property in placeholder.get_script().get_script_property_list():
			new[property.name] = placeholder[property.name]
		placeholders.append(new)
	
	return placeholders
