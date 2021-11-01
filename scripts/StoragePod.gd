extends Spatial

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
var all_tasks_complete: bool = false
onready var trigger_zone = get_node("TriggerZone")
onready var trigger_col = get_node("TriggerZone/CollisionShape")

func _ready():
	match(current_state):
		State.INPUT:
			$TriggerZone.connect("body_entered",self,"body_entered")
			$AnimationPlayer.connect("animation_finished",self,"animation_complete")
		State.TRANSIT:
			drone.immobile = false
			drone.translation = translation + Vector3(0,2,0)
		_:
			print("beep")
	
func open():
	$AnimationPlayer.play("open")
	$TriggerZone/CollisionShape.disabled = false
	
func close():
	$AnimationPlayer.play("close")
	$TriggerZone/CollisionShape.disabled = true
	
func body_entered(body):
	if body.name == "Drone":

		drone = body
		
		$AnimationPlayer.play("close")
		return
		
func animation_complete(anim_name):
	match(anim_name):
		"open":
			print("open complete")
		"close":
				return
				print("box spawning new level")
				# Respawn node outside of level tree.
				var reparent = entry_src.instance()
				reparent.current_state = State.TRANSIT
				reparent.translation = translation
				reparent.drone = drone
				
				var game_root = get_tree().get_root().get_node("Main/Viewport/Game")
				game_root.add_child(reparent)
				game_root.new_level()
				queue_free()
