extends Interactable

var open: bool = false
var capacity: int = 0

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")

func interact(item, interactor):
	if item == null:
		if open:
			anim.play_backwards("Open")
			UI.log("You close the washing machine.")
			open = false
		else:
			if capacity >= 3:
				UI.log("You turn the washing machine on.")
			else:
				anim.play("Open")
				UI.log("You open the washing machine.")
				open = true
	elif item is Clothes:
		if not open:
			UI.log("You should open the door first.")
		elif capacity < 3:
			UI.log("You toss the clothes in the washing machine.")
			capacity += 1
			interactor.inventory.consume_item()
		elif capacity >= 3:
			UI.log("The washing machine is full. Time to turn it on!")
