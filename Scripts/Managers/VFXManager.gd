extends "res://Scripts/ManagerForGroupedObjects.gd"

func get_group_name():
	return "vfx"

func spawn(scene, position):
	var spawned = scene.instance()
	
	spawned.position = position
	WorldManager.add_object(spawned)
	
	return spawned
