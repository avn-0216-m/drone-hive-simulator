extends Button

# Debug UI

func _ready():
	connect("pressed",self,"pressed")

func pressed():
	UI.dialog.queue("Welcome to Drone Hive Simulator! :)")
	UI.dialog.queue(UI.dialog.Portrait.MAIDEN)
	UI.dialog.queue("Here's a picture of me. Hehe.")
	UI.dialog.queue(-1)
	UI.dialog.queue("Do you like the beeps and boops of the way I talk? I'll let you in on a little secret...")
	UI.dialog.queue("My voice is actually sampled binaural beats, which is why it sounds all sine-y.")
	UI.dialog.queue("Specifically, my voice uses the 'relaxation' kind of binaural beats. It seemed very fitting for a game about hypnodrones. Hee hee hee.")
	
