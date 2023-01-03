extends Node

var menu_levelup = preload("res://Prefabs/Prefab_Menu_LevelUp.tscn")

func level_up():
	var inst = menu_levelup.instance()
	MapManager.instance.add_child(inst)
	pass
