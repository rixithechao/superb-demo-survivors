extends Node

var hud
var load_screen = preload("res://Prefabs/UI/Prefab_LoadScreen.tscn")
var load_screen_instance


signal load_screen_faded_in


func _ready():
	pass


func reset_timer():
	hud.timer.update_timer()
	pass


func show_load_screen():
	load_screen_instance = load_screen.instance()
	RootManager.top_ui.add_child(load_screen_instance)
	
func finish_load_screen():
	load_screen_instance.finish()

func load_screen_break(progress = null):
	if  progress != null:
		load_screen_instance.progress = progress
	#print("LOADING: ", progress)
	yield(get_tree().create_timer(0), "timeout")
	#yield(VisualServer, 'frame_pre_draw')
