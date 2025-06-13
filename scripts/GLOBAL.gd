extends Node

var beep = true
var color: Color = Color("#82d8d8")
var floor: int = 216
var completed_tasks: Array = []
var incomplete_tasks: Array = []
var task_goal: int = 1

func task_completed(task: Task):
	if completed_tasks.count(task) >= 1:
		UI.log("You've already completed this task!")
		return
	incomplete_tasks.erase(task)
	completed_tasks.append(task)
	task.task_complete = true
	UI.log("Task complete! (" + str(len(completed_tasks)) + "/" + str(len(completed_tasks) + len(incomplete_tasks)) + ")")

var color_mats = {
	"Composite/GameTexture/SubViewport/Game/PlayerBody/Mesh/Head/Screen": 0,
	"Composite/GameTexture/SubViewport/Game/PlayerBody/Mesh/Bow": 2
}

func add_item(item: Interactable):
	get_node("/root/Game/LevelGen")

func get_beep() -> bool:
	beep = !beep
	return beep
