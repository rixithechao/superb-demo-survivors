extends KinematicBody2D
class_name Character

func update_z():
	self.z_index = self.position.y*0.01
