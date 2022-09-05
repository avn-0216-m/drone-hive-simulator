extends Spatial

func _ready():
	
	$TweenUVX.interpolate_property($MeshInstance.material_override, "uv1_offset:x", 0, 1, 60)
	$TweenUVX.start()
	
	$TweenUVY.interpolate_property($MeshInstance.material_override, "uv1_offset:y", 0, 1, 120)
	$TweenUVY.start()
