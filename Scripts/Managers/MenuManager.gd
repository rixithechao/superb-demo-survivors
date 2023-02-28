extends Node

var resources = {
	"splashes": preload("res://Prefabs/UI/Prefab_Menu_SplashScreens.tscn"),
	"intro": preload("res://Prefabs/UI/Prefab_Menu_Intro.tscn"),
	"title": preload("res://Prefabs/UI/Prefab_Menu_Title.tscn"),
	"stages": preload("res://Prefabs/UI/Prefab_Menu_StageSelect.tscn"),
	"options": preload("res://Prefabs/UI/Prefab_Menu_Options.tscn"),
	"credits": preload("res://Prefabs/UI/Prefab_Menu_Credits.tscn"),
	"character": preload("res://Prefabs/UI/Prefab_Menu_CharacterSelect.tscn"),
	"levelup": preload("res://Prefabs/UI/Prefab_Menu_LevelUp.tscn"),
	"pause": preload("res://Prefabs/UI/Prefab_Menu_Pause.tscn"),
	"deathbg": preload("res://Prefabs/UI/Prefab_Menu_DeathBG.tscn"),
	"revive": preload("res://Prefabs/UI/Prefab_Menu_Revive.tscn"),
	"gameover": preload("res://Prefabs/UI/Prefab_Menu_GameOver.tscn"),
	"console": preload("res://Prefabs/UI/Prefab_Menu_CheatConsole.tscn"),
}

var pressed_any_key = false

var queue_priority = ["deathbg", "pause"]

var queue_array = []
var queue_current = ""
var queue_timer = 3

var stack = []
var instances_by_name = {}
var names_by_instance = {}


func queue(name):
	queue_array.append(name)

func clear_queue():
	queue_array.clear()


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
	return inst


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
		names_by_instance.erase(node)
		node.queue_free()



func open_next_in_queue():

	# Certain menus take priority
	var cut_in_line = false
	for  name in queue_priority:
		if  queue_array.has(name):
			queue_array.erase(name)
			queue_current = name
			cut_in_line = true
			break

	# Otherwise, process as normal
	if  not cut_in_line:
		queue_current = queue_array.pop_front()

	# Once the current queue is 
	open(queue_current)


func _process(_delta):

	# Process the queue
	if  queue_array.size() > 0  and  not instances_by_name.has(queue_current) and not PlayerManager.dead:
		queue_timer -= 1
		if  queue_timer <= 0:
			queue_timer = 3
			open_next_in_queue()
