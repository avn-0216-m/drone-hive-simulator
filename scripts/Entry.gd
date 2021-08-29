extends StaticBody

#onready var drone = get_node("../../../Drone")
onready var drone = get_node("../Drone")

func _ready():
	#drone.immobile = true
	drone.translation = $DroneGoesHere.get_global_transform().origin
	
#func _process(delta):
#	drone.translation = $DroneGoesHere.get_global_transform().origin
