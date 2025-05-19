extends Interactable

var open: bool = false

func interact(item: Node, interactor: Node):
	if not open:
		open = true
		UI.log("You open the door.")
		$AnimationPlayer.play("Open")
		$SFX.play()
		# Close the doors after a random long length of time to fuck w/ players.
		$Timer.start(randi_range(10,10000))

func timer_expired() -> void:
	open = false
	$AnimationPlayer.play_backwards("Open")
