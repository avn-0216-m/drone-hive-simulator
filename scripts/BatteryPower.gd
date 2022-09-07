extends Spatial
class_name BatteryPower

# Class that handles tracking of battery power.
# Emits a signal when battery is depleted.

var maximum_charge: int = 500
var drain_per_tick: int = 1
var overcharge: bool = false
var current_charge: int = maximum_charge

enum Level {
	EMPTY = 0, 
	LOW = 1,
	MID = 2,
	HIGH = 3,
	FULL = 4
}
var current_level = 4

signal battery_empty
signal battery_low
signal battery_mid
signal battery_high
signal battery_full

signal battery_recharged
signal battery_drained

func recharge(amount: int) -> int:
	# Adds given units to the total current charge.
	# Returns the current level.
	current_charge = current_charge + amount if overcharge else min(maximum_charge, current_charge + amount)
	return 0
	
func get_current_charge():
	return current_charge
	
func get_current_level():
	return current_level

func drain():
	current_charge = max(current_charge - drain_per_tick, 0)
