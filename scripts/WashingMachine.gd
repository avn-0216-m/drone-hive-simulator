extends Interactable

func _ready():
	super._ready()
	$AnimationPlayer.play("New Anim")
	rotation_degrees.y = -90 + (task.variant*10)

func interact(interactor):
	UI.log("Spinning around and around...")
	UI.log("Don't watch it too closely!")
