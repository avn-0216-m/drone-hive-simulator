extends Interactable

var thingies_fed: int = 0

func interact(item: Node, interactor: Node):
	if item is Thingie and thingies_fed < 3:
		thingies_fed += 1
		interactor.inventory.consume_item()
		match thingies_fed:
			1:
				UI.log("Yes!! This is what I want!!")
			2:
				UI.log("YESSS, so delicious!")
			3:
				UI.log("Okiecokies! I'm full nyeow :)")
				task_complete.emit(task)
	elif item is Thingie and thingies_fed >= 3:
		UI.log("Ooohh I couldn't!!! I'm SOOO FULL")
	elif item == null:
		UI.log("Gimmie somethin to bop!!!")
	elif not item is Thingie:
		UI.log("No!!! I only want to bop thingies!!")
