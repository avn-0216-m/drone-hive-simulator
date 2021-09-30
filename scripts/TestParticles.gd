extends Spatial

func _ready():
	$Timer.connect("timeout",self,"timeout")
	
func timeout():
	print("timer done")
	queue_free()
