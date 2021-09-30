extends Interactable

func _ready():
	cursor_offset = Vector3(0,2,0)

func interact():
	print("beep! you are interacting with a cube")

func _process(delta):
	velocity.y = apply_gravity(velocity)
	move_and_slide(velocity)
