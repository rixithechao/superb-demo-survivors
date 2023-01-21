extends Node


var group_name = "PLACEHOLDER_GROUP_NAME" setget ,get_group_name
var all = [] setget ,get_all
var count = 0 setget ,get_count


func get_group_name():
	return "PLACEHOLDER_GROUP_NAME"

func get_all():
	return get_tree().get_nodes_in_group(get_group_name())

func get_count():
	return get_all().size()



func get_nearest():
	
	var all_objs = get_all()
	
	# assume the first spawn node is closest
	var nearest = all_objs[0]
	var nearest_dist = INF
	var this_dist = 0
	
	var player_pos = PlayerManager.instance.global_position

	# look through enemies to see if any are closer
	for obj in all_objs:
		this_dist = obj.global_position.distance_to(player_pos)
		if this_dist < nearest_dist:
			nearest_dist = this_dist
			nearest = obj

	# reposition player
	return nearest

func get_random():
	if get_count() > 0:
		return get_all()[randi() % get_count()]
	else:
		return null
