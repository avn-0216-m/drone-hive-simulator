extends StaticBody3D

#onready var drone = get_node("../../../Drone")
@onready var drone = get_node("../Drone")

func _ready():
	if drone != null:
		drone.position = $DroneGoesHere.get_global_transform().origin
		drone.immobile = true
