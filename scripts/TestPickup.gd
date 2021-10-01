extends Pickup

func _process(delta):
	self.velocity.y = apply_gravity(self.velocity)
	move_and_slide(velocity)
