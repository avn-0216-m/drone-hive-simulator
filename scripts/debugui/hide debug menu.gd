extends Button

# Debug UI

func _ready():
	connect("pressed",self,"pressed")

func pressed():
	get_parent().get_parent().visible = false
