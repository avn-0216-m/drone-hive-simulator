extends Control

onready var activity_log = get_node("Anchor/ActivityLog")
onready var label_src = load("res://objects/ui/TemporaryLabel.tscn")

onready var task_list = get_node("Anchor/TaskList")

export var tick: Texture
export var cross: Texture
export var treasure: Texture

onready var dialog_label = get_node("Anchor/Dialog/Label")

var pitches = [0.85, 0.9, 0.95, 1.0, 1.05, 1.1, 1.15, 1.2]

var rng = RandomNumberGenerator.new()

var dialog_queue = []
var current_dialog = ""

func _ready():
	$CharacterWaitTime.connect("timeout",self,"push_character")
	$BoxWaitTime.connect("timeout",self,"read_dialog")
	$AnimationPlayer.connect("animation_finished",self,"dialog_anim_complete")

func log(text: String):
	var label = label_src.instance()
	label.text = text
	activity_log.add_child(label)

func add_task(task):
	return
	
func dialog_anim_complete(anim_name: String):
	match(anim_name):
		"dialog up":
			$CharacterWaitTime.start()
			read_dialog()

func set_tasks(tasks: Array):
	for task in tasks:
			task_list.add_item(task.title, tick if task.complete else cross)

func update_task(id, icon):
	task_list.set_item_icon(id, icon)

func queue_dialog(string: String, face: int = -1):
	dialog_queue.append(string)
	$AnimationPlayer.play("dialog up")


func read_dialog():
	dialog_label.text = ""
	current_dialog = dialog_queue.pop_front()
	if current_dialog == null:
		$AnimationPlayer.play("dialog down")
	else:
		$CharacterWaitTime.start()
		
func push_character():
	if current_dialog.empty():
		$BoxWaitTime.start()
		$CharacterWaitTime.stop()
	$AudioStreamPlayer.pitch_scale = pitches[rng.randi() % len(pitches)]
	$AudioStreamPlayer.play()
	var dequeued_character = current_dialog.substr(0,1)
	dialog_label.text += dequeued_character
	current_dialog = current_dialog.substr(1)
	match(dequeued_character):
		".", "?", "!":
			$CharacterWaitTime.wait_time = 0.6
		",":
			$CharacterWaitTime.wait_time = 0.3
		_:
			$CharacterWaitTime.wait_time = 0.02
