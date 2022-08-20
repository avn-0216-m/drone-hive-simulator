
var meshlib: Reference = load("res://scripts/data/MeshLib.gd").new()
var data: Array = [
	{
		"title": "Pick a flower from the garden.",
		"placeholders": [
			{
				"source": "res://objects/tasks/Garden.tscn",
				"area": Vector2(3,3),
				"index": meshlib.Data.GARDEN
			}
		]
	},
	{
		"title": "Hypnotize yourself.",
		"placeholders": [
			{
				"source": "res://objects/tasks/Hypnoscreen.tscn",
				"area": Vector2(5,5),
				"index": meshlib.Data.HYPNOSCREEN
			}
		]
	}
]
