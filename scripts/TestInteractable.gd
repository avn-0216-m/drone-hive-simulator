extends Interactable

onready var particles_src = load("res://objects/test/TestParticles.tscn")

func _ready():
	cursor_offset = Vector3(0,1,0)
	
func interact(interactor):
	print("beep! you are interacting with a cube")
	var particles = particles_src.instance()
	add_child(particles)

func _process(delta):
	velocity.y = apply_gravity(velocity)
	move_and_slide(velocity)
