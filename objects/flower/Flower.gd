extends Interactable

func interact(_item, _person):
	UI.log("Such beautiful nature!")
	task.task_complete = true
