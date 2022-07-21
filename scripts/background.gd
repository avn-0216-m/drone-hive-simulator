extends ColorRect

var wipe_direction: String = "IN"

func _ready():
	material.set_shader_param("screen_size", rect_size)

func game_over_1():
	material.set_shader_param("cutoff", 1)
	wipe_direction = "NONE"

func wipe_in():
	$CutoffTween.interpolate_property(material, "shader_param/cutoff", 1, -1, 5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	$CutoffTween.start()
	material.set_shader_param("slices", 5)
	material.set_shader_param("cutoff", 1)
	material.set_shader_param("cutoff_bottom_diff_multiplier", 0)
	
func wipe_out():
	wipe_direction = "OUT"
	material.set_shader_param("slices", 10)
	material.set_shader_param("cutoff", 0)
	material.set_shader_param("cutoff_bottom_diff_multiplier", 0.1)
