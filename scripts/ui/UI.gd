extends Control

@onready var activity_log = get_node("MarginContainer/Shading/Margin/LabelContainer")
@onready var label_src = load("res://objects/UI/TemporaryLabel.tscn")

@onready var task_list = get_node("Anchor/TaskList")

@onready var dialog = get_node("Anchor/Dialog")
@onready var battery = get_node("Anchor/Battery")

@export var max_chars_per_line: int = 28

var queue: Array = []

func _ready():
	$Timer.timeout.connect(timeout)
	
func timeout():
	var text = queue.pop_front()
	if text != null: 
		print_log(text)
	else:
		$Timer.stop()


func log(text: String):
	if $Timer.is_stopped():
		print_log(text)
		$Timer.start()
	else:
		queue.append(text)

func print_log(text: String):
	# TODO: add some fancy scanning to add line breaks to long lines in advance
	# so the text doesn't jump around when the visible_ratio is being tweened
	# for i in range 0, string length / 28 (?) maybe
	visible = true
	var label = label_src.instantiate()
	label.text = text
	activity_log.add_child(label)
	label.expired.connect(check_visibility)
	
func check_visibility():
	await get_tree().process_frame
	if activity_log.get_child_count() == 0:
		visible = false
