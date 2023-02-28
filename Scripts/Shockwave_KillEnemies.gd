extends Shockwave

export var kill_force : int = 0
export var prevent_drops : bool = false

func on_object_touched(object_node):
	if  object_node.data.kill_resistance <= kill_force:
		object_node.die(prevent_drops)
