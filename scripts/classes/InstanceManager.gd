extends Node

export var source_class: GDScript
export var source_data: GDScript
var source_placeholder: GDScript = load("res://scripts/classes/Placeholder.gd")
export var objects_per_level: int = 1 # Amount of objects added to active pool based on current level.
var source_pool: Array = [] # Represents unique list of all possible instancable objects.
var active_pool: Array = [] # Contains objects chosen to be instanced for a given level.

func _ready():
	source_pool = load_source_data()

func generate_active_pool(level_count: int) -> Array:
	active_pool.clear()
	for i in range(0,objects_per_level * level_count):
		active_pool.append(source_pool[0].duplicate())
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
