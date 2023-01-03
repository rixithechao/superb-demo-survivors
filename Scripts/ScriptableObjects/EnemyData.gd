tool
extends Resource
class_name EnemyData

enum EnemyMoveMode {
	FOLLOW,
	LINE,
	WAVE
}

export var name : String
export var graphics : Resource
export var max_hp : float = 5
export var damage : float = 1
export var move_speed : float = 1
export(EnemyMoveMode) var move_mode = EnemyMoveMode.FOLLOW
export var knockback_resistance : float = 0
export var freeze_resistance : float = 0   
export var kill_resistance : float = 0
export(float, 0,1) var hp_scaling
export var drop_table : Resource


func _ready():
	pass
