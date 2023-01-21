extends Node

var resources = {
	"splashes": preload("res://Prefabs/UI/Prefab_Menu_SplashScreens.tscn"),
	"title": preload("res://Prefabs/UI/Prefab_Menu_Title.tscn"),
	"stages": preload("res://Prefabs/UI/Prefab_Menu_StageSelect.tscn"),
	"levelup": preload("res://Prefabs/UI/Prefab_Menu_LevelUp.tscn"),
	"pause": preload("res://Prefabs/UI/Prefab_Menu_StageSelect.tscn"),
	"gameover": preload("res://Prefabs/UI/Prefab_Menu_GameOver.tscn"),
	"console": preload("res://Prefabs/UI/Prefab_Menu_CheatConsole.tscn")
}

var stack = []
var instances_by_name = {}
var names_by_instance = {}


func open(name):
	var menu_res = resources[name]
	var inst = menu_res.instance()
	stack.append(inst)
	instances_by_name[name] = inst
	names_by_instance[inst] = name
	
	#if UIManager.hud != null:
	#	UIManager.hud.add_child(inst)
	#else:
	RootManager.top_ui.add_child(inst)


func close_name(name):
	var inst = instances_by_name[name]
	if inst != null:
		stack.erase(inst)
		inst.queue_free()
		instances_by_name.erase(name)
		names_by_instance.erase(inst)


func close(node):
	if names_by_instance.has(node):
		var name = names_by_instance[node]
		close_name(name)
	else:
		stack.erase(node)
		node.queue_free()
		names_by_instance.erase(node)
