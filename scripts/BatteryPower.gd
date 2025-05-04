extends Node3D
class_name BatteryPower

# Class that handles tracking of battery power.
# Emits a signal when battery is depleted.

var maximum_charge: int = 100
var drain_per_tick: int = 5
var overcharge: bool = false
var current_charge: int = maximum_charge

signal battery_recharged(new_charge)
signal battery_charge_changed(new_charge)

func recharge(amount: int):
	current_charge = current_charge + amount if overcharge else min(maximum_charge, current_charge + amount)
	emit_signal("battery_recharged", current_charge)

func drain():
	current_charge = max(current_charge - drain_per_tick, 0)
	emit_signal("battery_charge_changed", current_charge)
