extends Interactable


var is_washing: bool = false
var is_full: bool = false
var is_open: bool = false 
var count: int = 0

@onready var anim: AnimationPlayer = get_node("AnimationPlayer")

func _ready():
	super()
	$Timer.timeout.connect(cycle_done)
	
func cycle_done():
	UI.log("The washing machine is done.")
	anim.play("RESET")
	is_washing = false
	is_full = false
	count = 0

func open():
	UI.log("You open the washing machine.")
	anim.play("Open")
	is_open = true

func close():
	UI.log("You close the washing machine.")
	anim.play_backwards("Open")
	is_open = false
	
func add_clothes(item, interactor):
	if is_washing:
		UI.log("The machine is busy.")
	elif is_full:
		UI.log("The machine is full. Turn it on.")
	elif not is_open:
		UI.log("Open the door first.")
	else:
		UI.log("You throw the clothes in.")
		interactor.inventory.consume_item()
		count += 1
		if count >= 3:
			UI.log("The machine is now full.")
			is_full = true

func interact(item, interactor):
	if item is Clothes:
		add_clothes(item, interactor)
	elif is_washing:
		UI.log("The machine is hard at work.")
	elif not is_open and is_full:
		UI.log("You start the machine.")
		anim.play("Wash")
		is_washing = true
		$Timer.start()
	elif is_open:
		close()
	elif not is_open:
		open()
