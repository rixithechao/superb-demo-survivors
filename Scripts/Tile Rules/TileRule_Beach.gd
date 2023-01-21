extends "res://Scripts/Tile Rules/TileRule_Default.gd"


static func process(position, heat, noise):
	return pow(max(heat, noise), 1.4)


func _ready():
	pass
