
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
	},
	{
		"title": "Wash clothes.",
		"placeholders": [
			{
				"source": "res://objects/tasks/WashingMachine.tscn",
				"area": Vector2(5,5),
				"index": meshlib.Data.WASHINGMACHINE,
			},
			{
				"source": "res://objects/tasks/Clothing.tscn",
				"area": Vector2(2,2),
				"index": meshlib.Data.CLOTHING
			},
			{
				"source": "res://objects/tasks/Clothing.tscn",
				"area": Vector2(2,2),
				"index": meshlib.Data.CLOTHING
			}
		]
	},
	{
		"title": "Put the NullCube on the matching NullPlate.",
		"placeholders": [
			{
				"source": "res://objects/tasks/NullPlate.tscn",
				"area": Vector2(2,2),
				"index": meshlib.Data.WEIGHTEDBUTTON
			},
			{
				"source": "res://objects/tasks/NullCube.tscn",
				"area": Vector2(2,2),
				"index": meshlib.Data.WEIGHTEDCUBE
			}
		]
	}
]
