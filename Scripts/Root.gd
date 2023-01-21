extends Node2D


func _ready():
	RootManager.top_ui = $TopUI
	RootManager.stage = $LoadedStage
