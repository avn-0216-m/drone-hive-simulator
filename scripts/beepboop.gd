extends Spatial

func _ready():
	if GLOBAL.get_beep():
		$Container/EO.frame = 1
		$Container/EO2.frame = 1
	else:
		$Container/EO.frame = 2
		$Container/EO2.frame = 2
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	$SFX.pitch_scale = rng.randf_range(0.7,1.3)
	get_node("SFX").play()
	
