extends StaticBody2D

export var transparent_for_player : bool = false

func _process(_delta):
	modulate.r = WorldManager.instance.tint.r
	modulate.g = WorldManager.instance.tint.g
	modulate.b = WorldManager.instance.tint.b
	
	if  PlayerManager.instance == null  or  not is_instance_valid(PlayerManager.instance):
		return

	# Make transparent for the player if need be
	var p_dist = PlayerManager.instance.global_position - global_position
	var transparent_check = (p_dist.length() < 192  and  p_dist.y < 0  and  transparent_for_player)
	var dest_a = (0.33 if transparent_check else 1.00)
	
	modulate.a = lerp(modulate.a, dest_a, 0.1)
