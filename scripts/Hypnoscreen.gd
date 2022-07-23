extends Interactable


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	print("beepboop")

func interact(interactor):
	UI.log("Look closer. Good drone.")
