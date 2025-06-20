extends Interactable

var open: bool = false

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")

func interact(item, interactor):
	if item == null:
		if open:
			anim.play_backwards("Open")
			UI.log("You close the washing machine.")
			open = false
		else:
			anim.play("Open")
			UI.log("You open the washing machine.")
			open = true
	elif item is Roomba:
		UI.log("Do not the roomba.")
