extends Spatial


func _ready():
	$Tween.interpolate_property($MeshInstance, "rotation_degrees:y", 0, 360, 120)
	$Tween.start()
