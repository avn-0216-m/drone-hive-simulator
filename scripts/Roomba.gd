extends Pickup

var speed = 2
var moving = true
var searched = false

func _ready():
	super._ready()
	type = Type.DIRECT
	$AnimationPlayer.play("Clean")
	source = load("res://objects/bonus/Roomba.tscn").instantiate()
	source.scale = Vector3(0.15, 0.15, 0.15)
	source.parent = parent
	source.interactable_name = "another, smaller roomba"
	source.infinite = false
	#connect("picked_up",self,"empty_dustbin")
	
func interact(interactor):
	UI.log("You search the dustbin.")
	if searched and infinite:
		UI.log("The dustbin is empty.")
		return null
	else:
		searched = true
		return super.interact(interactor)
	
func _physics_process(delta):
	if moving:
		set_velocity(get_global_transform().basis.z * speed)
		move_and_slide()

func body_nearby(body):
	moving = false
	$AnimationPlayer.play("Bump")

func anim_complete(anim_name):
	match anim_name:
		"Bump":
			$AnimationPlayer.play("Clean")
			$Tween.interpolate_property(self, "rotation_degrees:y", rotation_degrees.y, rotation_degrees.y + 30, 0.5)
			$Tween.start()

func tween_complete(object, key):
	moving = true
