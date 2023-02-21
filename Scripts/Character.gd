extends KinematicBody2D
class_name Character

export var gravity : float = 7.5

var height : float = 0
var air_speed : float = 0


func get_z_top():
	return height + 2


func _process(delta):
	air_speed -= gravity*delta
	height = max(0, height + air_speed*delta)
	
	if  get_node_or_null("Graphic") != null:
		$Graphic.height = height


func update_z():
	self.z_index = self.position.y*0.01
