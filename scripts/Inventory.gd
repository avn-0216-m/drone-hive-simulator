extends Spatial

onready var drone = get_node("../Viewport/Game/Drone")
onready var camera = get_node("../Viewport/Game/CameraContainer/MainCamera")
var distance_between_slots: float = 0.4
onready var total_slots: int = len(get_children())
var center_slot: int = 0

func _process(delta):

	if visible:
		translation = drone.transform.origin + Vector3(0,2.5,0)
		#look_at(camera.transform.origin, Vector3(0,1,0))

func _ready():
	var slot_translation = distance_between_slots * -(total_slots/2)
	print("start dist")
	print(slot_translation)
	print(total_slots)
	print(distance_between_slots)
	
	# If even amount of slots, offset by half the distance so the middle
	# slot is still directly above the drone.
	if total_slots % 2 == 0:
		slot_translation += (distance_between_slots/2)
	for slot in get_children():
		slot.translation = Vector3(slot_translation, 0, 0)
		slot_translation += distance_between_slots
