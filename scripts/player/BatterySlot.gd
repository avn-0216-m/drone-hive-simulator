extends Sprite3D
class_name BatterySlot

var maximum_charge: int = 100
var current_charge: int = maximum_charge
var percentage: float = 0.0

onready var particles_src = load("res://objects/OneShotParticles.tscn")

func track(obj: BatteryPower):
	maximum_charge = obj.maximum_charge
	obj.connect("battery_recharged", self, "on_battery_recharge")
	obj.connect("battery_charge_changed", self, "on_battery_change")

func get_color():
	return material_override.albedo_color

func output():
	UI.log("Battery: " + str(percentage * 100) + "%")

func select(arg):
	return

func on_battery_recharge(new_charge):
	on_battery_change(new_charge)
	var particles_inst = particles_src.instance()
	particles_inst.emitting = true
	add_child(particles_inst)

func on_battery_change(new_charge):
	
	current_charge = new_charge
	percentage = float(new_charge)/float(maximum_charge)
	
	$Pip4.visible = true
	$Pip3.visible = true
	$Pip2.visible = true
	$Pip.visible = true
	
	if percentage < 0.75:
		$Pip4.visible = false
	if percentage < 0.50:
		$Pip3.visible = false
	if percentage < 0.25:
		$Pip2.visible = false
	if percentage == 0.0:
		$Pip.visible = false
