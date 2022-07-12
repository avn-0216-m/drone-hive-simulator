extends Resource

class task:
	var title: String = "UNTITLED TASK"
	var objects: Array = []
	
	func _init(title = "UNTITLED TASK", objects = []):
		self.title = title
		self.objects = objects

class object:
	var source: String
	var area: Vector2 = Vector2(0,0)
	var index: int = -1
	
	func _init(source = "MISSING SOURCE", index = -1, area = Vector2(0,0)):
		self.source = source
		self.area = area
		self.index = index # index of the placeholder object in the meshlibrary.

var garden = object.new("res://objects/tasks/Garden.tscn", 2, Vector2(4,4))

var objects = [] # setup in _init

func _init():
	# Setting up objects array so that each object is at the index of its
	# meshinstance index, so it can be looked up when the gridmap is being
	# intanced.
	
	objects.resize(100)
	
	objects[garden.index] = garden

var tasks = [
	task.new("Enjoy the pretty garden.", [garden])
]


