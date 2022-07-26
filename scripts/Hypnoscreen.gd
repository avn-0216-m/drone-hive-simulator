extends Interactable

var static_mat = load("res://materials/static.tres")

var start_count = 11
var count = start_count

func _ready():
	._ready()
	$Nearby.connect("body_entered",self,"something_nearby")
	$Nearby.connect("body_exited",self,"something_left")
	$Timer.connect("timeout",self,"count_down")
	
func something_left(body):
	if body is Drone:
		$Screen/SpiralBackground.set_material_override(static_mat)
		$Screen/SpiralBackground/Spiral.visible = false
		$Screen/SpiralBackground/Spiral/AnimationPlayer.stop(true)
		count = start_count
		$Timer.stop()

func something_nearby(body):
	if body is Drone and type != Type.NONE:
		$Screen/SpiralBackground.set_material_override(null)
		$Screen/SpiralBackground/Spiral.visible = true
		$Screen/SpiralBackground/Spiral/AnimationPlayer.play("spiral")
		$Timer.start()
		UI.dialog.queue(UI.dialog.Portrait.MAIDEN)
		UI.dialog.queue("Buddy, I've got just one thing to say to you...")
		UI.dialog.queue(UI.dialog.Portrait.YOUSHOULDHYPNOTIZEYOURSELF)
		UI.dialog.queue("You should hypnotize yourself... NOW!")

func count_down():
	if count < 0 or type == Type.NONE:
		return
	count -= 1
	UI.log(str(count) + "...")
	if count == 0:
		UI.log("Good drone. Your owner loves you.")
		UI.dialog.queue("That feels good, doesn't it? Just keep sinking deeper and deeper as you complete all your tasks throughout these halls.")
		UI.dialog.queue("Just as a good drone ought to do.")
		emit_signal("task_completed", task_id)
		$Timer.stop()
		type = Type.NONE

func interact(interactor):
	UI.log("Look closer. Good drone.")
