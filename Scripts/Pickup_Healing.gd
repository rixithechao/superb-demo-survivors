extends "res://Scripts/Pickup.gd"

export var health_granted = 30


func pickup_effect():
	PlayerManager.heal(health_granted)
	pass
