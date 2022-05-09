extends Node

# Script for coordinating the completion of tasks.

export(GDScript) var MeshLib

var task_tally = 0 # Tracks current-level task ID.

var ratio: float = 3.0 # One task per three points of difficulty.
var bird_factor: int = 3 # How often Anna appears.

var rng = RandomNumberGenerator.new()

var placeholders: Array # Gridmap cells to be instanced into real objects.
var active_tasks: Array # In-progress tasks for the current level.
var task_pool: Array # All tasks that are eligble to randomly spawn in a level.
var objects: Array # All objects used in all tasks.

# Special tasks that exist outside the standard pool.
var anna_task: Task # Birdy.
var entry: Task # Entry toybox.
var exit: Task # Exit toybox.

class TaskObject:
	var source: String
	var area: Vector2
	var index: int
	
	func _init(source, area, index):
		self.source = source
		self.area = area
		self.index = index

class Task:
	var id: int
	var complete: bool = false
	var title: String
	var objects: Array
	
	func _init(title = "N/A", objects = []):
		self.title = title
		self.objects = objects

class Placeholder:
	var id: int
	var index: int
	var pos: Vector3
	
	func _init(pos: Vector3, index: int, id: int):
		self.pos = pos
		self.index = index
		self.id = id

func _ready():
	
	# init task objects
	var garden = TaskObject.new("res://objects/tasks/Garden.tscn", Vector2(2,2), MeshLib.data.Garden)
	var anna = TaskObject.new("res://objects/tasks/Anna.tscn", Vector2(0,0), MeshLib.data.Anna)
	var cube = TaskObject.new("res://objects/tasks/WeightedCube.tscn", Vector2(0,0), MeshLib.data.WeightedBox)
	var button = TaskObject.new("res://objects/tasks/WeightedButton.tscn", Vector2(2,2), MeshLib.data.WeightedButton)
	
	objects = [
		garden, anna,
		cube, button
	]
	
	# insert objects into objects array based on meshinstance placeholder index
	# so they can be reverse lookup'd during the instantiation process.
	var temp = objects.duplicate()
	objects.clear()
	objects.resize(100)
	for object in temp:
			objects[object.index] = object
	
	# Setup tasks outside of the standard pool
	anna_task = Task.new("Anna has a gift for you!", [anna])
	
	# init tasks
	task_pool = [
		Task.new("Enjoy the pretty garden.", [garden]),
		Task.new("Put the box on the button.", [cube, button])
	]
	
	# resize so levels can have up to 100 tasks at a time.
	active_tasks.resize(100)
	
func add_task(task: Task):
	pass

func add_object_placeholder(pos: Vector2, index: int):
	placeholders.append(Placeholder.new(Vector3(pos.x, 1, pos.y), index, task_tally))
	task_tally += 1
	
func get_object_data_from_meshlib_index(index: int) -> Object:
	print(objects)
	return objects[index]
	
func associate_object_with_task(node, id):
	active_tasks[id].objects.append(node)
	# also setup signal emissions here
	
func generate_task_list(difficulty: int) -> Array:
	
	rng.randomize()
	
	var generated: Array = []
	if difficulty % bird_factor == 0 or true:
		print("Adding Anna placeholder.")
		generated.append(anna_task)
	for i in range(0,ceil(float(difficulty)/ratio)):
		print("Adding random task to task list.")
		generated.append(task_pool[randi() % task_pool.size()])
	
	return generated
	
func task_complete(id):
	print("Task complete.")
