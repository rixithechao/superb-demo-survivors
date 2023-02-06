extends Node


static func process(_position, heat, noise):
	return max(heat, noise)


func _ready():
	pass
