extends Interactable
class_name Thingie

func _ready():
	super()
	$MeshInstance3D.mesh.material.albedo_color = Color(
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		1.0
	)


func _process(delta):
	if position.y < -3:
		UI.log("You done fucked up.")
		print(position)
		position.y = 10
		process_mode = Node.PROCESS_MODE_DISABLED
