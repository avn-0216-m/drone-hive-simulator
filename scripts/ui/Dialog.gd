extends Control

enum Portrait {
	MAIDEN = 0,
	YOUSHOULDHYPNOTIZEYOURSELF = 1
}

var portraits = [
	load("res://sprites/maiden/front/maiden1.png"),
	load("res://sprites/maiden/front/you should brainwash yourself NOW.png")
]

onready var dialog_label = get_node("Panel/Margins/Anchor/Label")
onready var dialog_counter = get_node("Panel/Margins/Anchor/DialogCounter")

var pitches = [0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2]

var rng = RandomNumberGenerator.new()

var dialog_queue = []
var current_dialog = ""

func _ready():
	$Portrait.visible = false

func dialog_anim_complete(anim_name: String):
	match(anim_name):
		"dialog up":
			$CharacterWaitTime.start()
			read_dialog()
		"dialog down":
			$Portrait.visible = false
			$Portrait/MarginContainer/ColorRect.texture = null

func queue(queue_data):
	if dialog_queue.empty():
		$AnimationPlayer.play("dialog up")
	dialog_queue.append(queue_data)
	update_dialog_counter()
	
func update_dialog_counter():
	dialog_counter.text = str(len(dialog_queue))

func read_dialog():
	update_dialog_counter()
	dialog_label.text = ""
	current_dialog = dialog_queue.pop_front()
	match typeof(current_dialog):
		TYPE_INT:
			# update portrait and call read dialog again
			match(current_dialog >= 0):
				true:
					$Portrait/MarginContainer/ColorRect.texture = portraits[current_dialog]
					$Portrait.visible = true
					read_dialog()
				false:
					$Portrait/MarginContainer/ColorRect.texture = null
					$Portrait.visible = false
					read_dialog()
		TYPE_STRING:
			$CharacterWaitTime.start()
		TYPE_NIL:
			$AnimationPlayer.play("dialog down")
		
		
func push_character():
	if current_dialog.empty():
		$BoxWaitTime.start()
		$CharacterWaitTime.stop()
	
	$AudioSFX.get_children()[randi() % $AudioSFX.get_child_count()].play()
	var dequeued_character = current_dialog.substr(0,1)
	dialog_label.text += dequeued_character
	current_dialog = current_dialog.substr(1)
	match(dequeued_character):
		".", "?", "!":
			$CharacterWaitTime.wait_time = 0.6
		",":
			$CharacterWaitTime.wait_time = 0.3
		_:
			$CharacterWaitTime.wait_time = 0.05
