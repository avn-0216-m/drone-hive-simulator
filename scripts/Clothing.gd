extends Pickup

func _ready():
	._ready()
	$AnimatedSprite3D.frame = randi() % $AnimatedSprite3D.get_sprite_frames().get_frame_count("clothes")

func on_drop():
	rotation_degrees.y += randi() % 45
