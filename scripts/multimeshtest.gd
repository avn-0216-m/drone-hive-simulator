extends MultiMeshInstance


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(0,multimesh.instance_count):
		self.multimesh.set_instance_transform(i, Transform(Basis(), Vector3(0, i, 0)))
