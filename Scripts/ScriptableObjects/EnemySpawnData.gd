extends Resource
class_name EnemySpawnData

export var interval : float = 1
export var delay : float = 0
export(Array, PackedScene) var enemies = ["res://Prefabs/Enemies/Prefab_Enemy_Furba.tscn"]

func _ready():
	pass
