extends "res://Scripts/ManagerForGroupedObjects.gd"

func get_group_name():
	return "projectile"

func spawn(weapon_data, volley_index = 0):
	if weapon_data.projectile == null:
		return
	
	var spawned = weapon_data.projectile.instance()
	spawned.volley_index = volley_index
	spawned.weapon_data = weapon_data

	WorldManager.add_object(spawned)
	spawned.position = PlayerManager.instance.position
