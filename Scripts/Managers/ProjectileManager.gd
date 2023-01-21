extends "res://Scripts/ManagerForGroupedObjects.gd"

func get_group_name():
	return "projectile"

func spawn(weapon_data):
	if weapon_data.projectile == null:
		return
	
	var spawned = weapon_data.projectile.instance()
	spawned.weapon_data = weapon_data

	WorldManager.add_object(spawned)
	spawned.position = PlayerManager.instance.position
