extends Resource
class_name EnemySpawnData

export(Array, Resource) var enemies = [load("res://Data Objects/Enemies/Enemy_Furba.tres")]
export var total : int = 1
export var interval : float = 1

func _ready():
	pass
