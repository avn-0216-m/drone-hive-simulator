extends Spatial

func _ready():
	
	var beep = GLOBAL.get_beep()
	
	if beep:
		$Container/EO.frame = 1
		$Container/EO2.frame = 1
	else:
		$Container/EO.frame = 2
		$Container/EO2.frame = 2
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	if beep:
		$SFX.pitch_scale = rng.randf_range(0.8,1.3)
	else:
		$SFX.pitch_scale = rng.randf_range(0.5,0.7)
	get_node("SFX").play()
	
