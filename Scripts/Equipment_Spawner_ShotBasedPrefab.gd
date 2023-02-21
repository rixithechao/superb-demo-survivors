extends Equipment_Spawner


export (Dictionary) var shot_map


func pick_prefab():
	var lvl = data.get_current_level()
	var chosen = projectile_prefabs[0]
	
	if  shot_map.has(projectiles_left):
		var idx = shot_map[projectiles_left]
		if  projectile_prefabs.size() > idx:
			chosen = projectile_prefabs[idx]
	
	return chosen
