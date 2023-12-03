extends Node

var beep = true

func get_beep() -> bool:
	beep = !beep
	return beep
