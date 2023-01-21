extends "res://Scripts/Pickup.gd"

export var coins_granted = 1


func pickup_effect():
	PlayerManager.give_coins(coins_granted)
	pass
