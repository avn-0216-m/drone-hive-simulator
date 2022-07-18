extends Pickup

func use_on(obj):
	if obj is WeightedButton:
		UI.log("Yeah okay")
		return true
