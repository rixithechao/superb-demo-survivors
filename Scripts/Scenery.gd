extends StaticBody2D

func _process(_delta):
	modulate = WorldManager.instance.tint
	
	# I really should have like, a world actor base class with this
	#self.z_index = self.position.y
	pass
