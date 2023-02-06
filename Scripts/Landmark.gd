extends Node2D

var dump_delay : int = 16

var child_objects = []


func dump():
	var parnt = WorldManager.world_objects_node

	for child in get_children():
		child_objects.append(child)
		remove_child(child)
		child.position += self.position
		parnt.add_child(child)


func unload():
	var parnt = WorldManager.world_objects_node

	for child in child_objects:
		parnt.remove_child(child)
		add_child(child)
	
	self.queue_free()



func _process(_delta):
	dump_delay = max(-1, dump_delay-1)
	if  dump_delay == 0:
		dump()
	
