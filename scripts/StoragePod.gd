extends StaticBody

onready var entry_src = load("res://objects/StorageBox.tscn")
enum State {INPUT, TRANSIT, OUTPUT}
# States
# INPUT
# The exit for a level, calls new_level() when a drone enters with all tasks complete.
# TRANSIT
# The node has been reparented to Game and is transporting the drone to the next level.
# OUTPUT
# The node has arrived at the next level and is now non-functional.
var current_state = State.INPUT
var drone: KinematicBody

func _ready():
	match(current_state):
		State.INPUT:
			$Area.connect("body_entered",self,"body_entered")
		State.TRANSIT:
			drone.immobile = false
			drone.translation = translation + Vector3(0,2,0)
		_:
			print("beep")
	
func body_entered(body):
	if body.name == "Drone":
		# Respawn node outside of level tree.
		
		var reparent = entry_src.instance()
		reparent.current_state = State.TRANSIT
		reparent.translation = translation
		reparent.drone = body
		
		var game_root = get_tree().get_root().get_node("Main/Viewport/Game")
		game_root.add_child(reparent)
		game_root.new_level()
		queue_free()
