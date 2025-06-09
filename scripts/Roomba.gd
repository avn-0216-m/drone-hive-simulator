extends Interactable

func interact(item, interactor):
	UI.log("You pet the roomba.")
	UI.log("It's very happy. :)")
	task_complete.emit(task)
