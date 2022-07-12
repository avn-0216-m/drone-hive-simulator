extends ItemList

onready var font: DynamicFontData = preload("res://fonts/vcr osd.ttf")

func add_task(task):
	
	add_item(task.title)
	
	
	print("adding label for task")
	var label = Label.new()
	var font = DynamicFont.new()
	font.font_data = font
	font.size = 40
	font.use_mipmaps = true
	label.set("custom_fonts/font", font)
	label.text = task.title
	add_child(label)
