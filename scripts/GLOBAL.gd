extends Node

var beep = true

var color: Color = Color("#82d8d8")

var color_mats = {
	"Composite/GameTexture/Viewport/Game/PlayerBody/Mesh/Head/Screen": 0,
	"Composite/GameTexture/Viewport/Game/PlayerBody/Mesh/Bow": 2
}

func get_beep() -> bool:
	beep = !beep
	return beep

