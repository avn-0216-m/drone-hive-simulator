extends Node

# Script for coordinating the completion of tasks.

var exit_box: Node
var tasks = []


func task_complete(node):
	print("Task completed. :)")

func get_tasks():
	tasks = get_tree().get_nodes_in_group("Completable")
