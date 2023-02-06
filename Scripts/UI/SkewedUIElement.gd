extends Node2D

export var skew : float = -0.125


func _process(_delta):
	transform.y = Vector2(skew,1)
	pass
