extends Equipment_Spawner


export (Array, int) var min_levels



func pick_prefab():
	var lvl = data.get_current_level()
	var chosen = projectile_prefabs[0]
	
	for  i in range(projectile_prefabs.size(), 0, -1):
		if  min_levels.size() > i  and  min_levels[i] <= lvl:
			chosen = projectile_prefabs[i]
			break

	return chosen
