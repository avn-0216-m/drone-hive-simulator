extends Node3D

func _process(delta):
	if $Static.visible:
		$Static.mesh.material.albedo_texture.noise.offset = Vector3(randf() * 100, randf() * 100, 0)
