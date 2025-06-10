extends Interactable

func _ready():
	super()
	$MeshInstance3D.mesh.material.albedo_color = Color(
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		randf_range(0.0, 1.0),
		1.0
	)
