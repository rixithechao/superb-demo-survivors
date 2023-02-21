extends "res://Scripts/MapEvent.gd"


var cannonballs_scene_preload = load("res://Prefabs/Map Events/Prefab_MapEvent_Cannonballs.tscn")


var boss_killed = false



func _ready():
	StageManager.connect("stage_cleared", self, "_on_stage_cleared")
	

func _on_stage_cleared(signal_data):
	if  not boss_killed:
		boss_killed = true
		signal_data.cancelled = true
		$AnimationPlayer.play("Sequence_End")


func _on_CannonballsTimer_timeout():
	if  not boss_killed:
		$SubAnimations.play("Cannonballs")
		pass # Replace with function body.
