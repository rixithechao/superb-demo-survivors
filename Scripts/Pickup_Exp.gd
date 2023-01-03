extends "res://Scripts/Pickup.gd"

export var exp_granted = 1


func pickup_effect():
	PlayerManager.give_exp(exp_granted)
	pass
