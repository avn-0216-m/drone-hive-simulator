extends Node

var beep = true
var color: Color = Color("#82d8d8")
var floor: int = 216

var color_mats = {
	"Composite/GameTexture/SubViewport/Game/PlayerBody/Mesh/Head/Screen": 0,
	"Composite/GameTexture/SubViewport/Game/PlayerBody/Mesh/Bow": 2
}

func get_beep() -> bool:
	beep = !beep
	return beep
