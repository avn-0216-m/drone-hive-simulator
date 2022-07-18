extends Node

# Script for coordinating the completion of tasks.

var MeshLib = load("res://scripts/data/meshlib.gd")

var task_tally = 0 # Tracks current-level task ID.

var ratio: float = 3.0 # One task per three points of difficulty.
var bird_factor: int = 3 # How often Anna appears.

var rng = RandomNumberGenerator.new()

var active_tasks: Array setget set_active_tasks, get_active_tasks # In-progress tasks for the current level.
var task_pool: Array

onready var task_list_ui = get_tree().get_root().get_node("Main/TaskList")

func get_active_tasks() -> Array:
	return active_tasks
	
func set_active_tasks(new_tasks: Array):
	active_tasks = new_tasks

class Task:
	extends Node
	var task_id: int
	var complete: bool = false
	var title: String
	var objects: Array # instanciated objects.
	var placeholders: Array
	var optional: bool = false # If the task is required to complete the level.
	
	func _init(title = "N/A", placeholders = []):
		self.title = title
		self.placeholders = placeholders

class Placeholder:
	extends Node
	var index: int # MeshLib index
	var pos: Vector3
	var source: String = ""
	var area: Vector2
	
	func _init(index = -1, source = "", area = Vector2(1,1), pos: Vector3 = Vector3(0,0,0)):
		self.pos = pos
		self.index = index
		self.source = source
		self.area = area

func _ready():
	# Do not copy from the task pool directly or else all the references
	# will be the same.
	# I've tried .new and .instance and .duplicate and nothing seems to work.
	# See clone_tasks() for workaround.
	task_pool = [
			Task.new("Enjoy the pretty garden", [
				Placeholder.new(MeshLib.Data.GARDEN, "res://objects/tasks/Garden.tscn", Vector2(3,3))
				]),
			Task.new("Put the cube on the button", [
				Placeholder.new(MeshLib.Data.WEIGHTEDBUTTON, "res://objects/tasks/WeightedButton.tscn"),
				Placeholder.new(MeshLib.Data.WEIGHTEDCUBE, "res://objects/tasks/WeightedCube.tscn")
			])
		]
	
func clone_tasks(found_tasks: Array) -> Array:
	
	# Using a counter like this assumes the task list will not change
	# throughout the level.
	# If new tasks are added, this will break.
	
	var counter: int = 0
	var cloned_tasks: Array = []
	for task in found_tasks:
		var cloned_task = Task.new(task.title)
		for placeholder in task.placeholders:
			cloned_task.placeholders.append(
				Placeholder.new(
					placeholder.index, 
					placeholder.source, 
					placeholder.area))
		cloned_task.task_id = counter 
		counter += 1
		cloned_tasks.append(cloned_task)
	return cloned_tasks
	
func generate_task_list(difficulty: int) -> Array:
	
	rng.randomize()
	
	var found_tasks = []
	var cloned_tasks = []
	for i in range(0,ceil(float(difficulty)/ratio)):
		print("Adding random task to task list.")
		# Gotta do this the hard way because if we append tasks from the pool
		# wholesale then they all share the same references, which is bad.
		# so I gotta deep-duplicate the task and placeholder before I append
		# it.
		found_tasks.append(task_pool[randi() % task_pool.size()])
	
	active_tasks = clone_tasks(found_tasks)
	return active_tasks

func on_task_completion(task_id: int):
	if !active_tasks[task_id].complete:
		active_tasks[task_id].complete = true
		UI.log("Task complete!")
		UI.update_task(task_id, UI.tick)
