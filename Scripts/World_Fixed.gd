extends "res://Scripts/World.gd"


func _ready():
	._ready()
	StageManager.on_stage_generated()
	pass
