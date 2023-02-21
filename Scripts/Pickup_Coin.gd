extends "res://Scripts/Pickup.gd"

export var coins_granted = 1



func pickup_effect():
	PlayerManager.give_coins(coins_granted)
	pass


func _ready():
	SaveManager.settings.connect("settings_changed", self, "_on_settings_changed")

func _on_settings_changed():
	var coin_tex = load("res://Textures/Items/spr_pickup_coin_a2xt.png")
	var tooth_tex = load("res://Textures/Items/spr_pickup_tooth_a2xt.png")

	$Sprite.texture = (tooth_tex if  SaveManager.settings.teeth  else coin_tex)
