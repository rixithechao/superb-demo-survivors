extends "res://Scripts/PlayerCharacter.gd"


func on_revive_check(signal_data):
	signal_data.cancelled = true


func _ready():
	PlayerManager.connect("revive_check", self, "on_revive_check")
	pass
