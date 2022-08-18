extends Interactable

func _ready():
	$AnimationPlayer.play("New Anim")

func interact(interactor):
	UI.log("Spinning around and around...")
	UI.log("Don't watch it too closely!")
