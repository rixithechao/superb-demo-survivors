extends Node

var heatmap_texture = ImageTexture.new()

var instance
var world_objects_node
var map_events_node


func add_node_to_world_stack(node, stack):
	var parnt = node.get_parent()
	if  parnt != null:
		parnt.remove_child(node)
	stack.add_child(node)
	pass

func add_object(node):
	add_node_to_world_stack(node, world_objects_node)

func add_map_event(node):
	add_node_to_world_stack(node, map_events_node)



func _ready():
	pass
