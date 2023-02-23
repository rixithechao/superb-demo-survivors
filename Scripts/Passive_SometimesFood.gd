extends Equipment


export var food_prefab : PackedScene




func _on_DropTimer_timeout():
	var spawn_pos = global_position + Vector2(rand_range(400,600), 0).rotated(deg2rad(rand_range(0,360)))
	
	StageManager.spawn_pickup(food_prefab, spawn_pos)
	
	$DropTimer.start(20 - 2*data.get_current_level())
