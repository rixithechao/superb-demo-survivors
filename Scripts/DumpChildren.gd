extends Node2D


func _ready():
	var parnt = get_parent()
	
	for child in get_children():
		remove_child(child)
		parnt.add_child(child)
		pass
	
	self.queue_free()
