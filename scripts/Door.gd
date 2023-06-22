extends Interactable

var open = false
onready var open_deg = get_parent().rotation_degrees.y - 90
onready var closed_deg = get_parent().rotation_degrees.y

func interact(interactor):
	$Tween.interpolate_property(
		get_parent(),
		"rotation_degrees:y",
		get_parent().rotation_degrees.y,
		closed_deg if open else open_deg,
		1,
		$Tween.EASE_OUT)
	$Tween.start()
	open = !open
