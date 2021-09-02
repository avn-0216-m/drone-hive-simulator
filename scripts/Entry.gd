extends StaticBody

#onready var drone = get_node("../../../Drone")
onready var drone = get_node("../Drone")

func _ready():
	if drone != null:
		drone.translation = $DroneGoesHere.get_global_transform().origin
		drone.immobile = true
