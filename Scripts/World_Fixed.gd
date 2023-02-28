extends "res://Scripts/World.gd"
class_name World_Fixed

func _ready():
	._ready()
	StageManager.on_stage_generated()
	pass
