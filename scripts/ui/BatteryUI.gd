extends Control

var tracking: Node

func track(node: Node):
	return

func _ready():
	$Tween.interpolate_property($ChargeParent, "scale:x", 1, 10, 5)
	$Tween.start()

func _process(delta):
	$BatteryLeft.position.x = -16 * ($ChargeParent.scale.x * 2)
	$BatteryRight.position.x = 16 * ($ChargeParent.scale.x * 2)
