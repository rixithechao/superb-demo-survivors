extends "res://Scripts/ManagerForGroupedObjects.gd"

func get_group_name():
	return "vfx"

func spawn(scene, position):
	var spawned = scene.instance()
	
	WorldManager.add_object(spawned)
	spawned.position = position
	
	return spawned
