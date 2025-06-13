extends CharacterBody3D

var angle = Vector3.ZERO
@export var contents: PackedScene


func _ready():
	GlobalCam.track(self, true)
	angle.x = randf_range(0.0, 0.5)
	angle.y = randf_range(0.0, 0.5)
	angle.z = randf_range(0.0, 0.5)
	$Box.finished.connect(queue_free)
	
func _physics_process(delta):
	rotation_degrees += angle
	velocity.y -= 0.5
	move_and_slide()
	if is_on_floor():
		var contents_obj = contents.instantiate()
		contents_obj.position = position
		get_parent().add_child(contents_obj)
		$CollisionShape3D/MeshInstance3D.visible = false
		$CollisionShape3D.disabled = true
		$Peanuts.emitting = true
		$Box.emitting = true
