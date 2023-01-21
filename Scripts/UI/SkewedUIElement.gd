extends Node2D

export onready var skew : float = -0.125


func _ready():
	transform.y = Vector2(skew,1)
	pass
