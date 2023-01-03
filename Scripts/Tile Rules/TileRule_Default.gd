extends Node


static func process(position, heat, noise):
	return max(heat, noise)


func _ready():
	pass
