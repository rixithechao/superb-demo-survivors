extends Node

var hud
var load_screen = preload("res://Prefabs/UI/Prefab_LoadScreen.tscn")
var load_screen_instance


signal load_screen_faded_in


func _ready():
	pass


func show_load_screen():
	RootManager.top_ui.add_child(load_screen.instance())
	pass
	
func finish_load_screen():
	load_screen_instance.finish()

func load_screen_break(progress):
	load_screen_instance.progress = progress
	#print("LOADING: ", progress)
	yield(VisualServer, 'frame_pre_draw')
