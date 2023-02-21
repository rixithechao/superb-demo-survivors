tool
extends Resource
class_name EnemyData


export var name : String
export(Resource) var stats setget set_custom_stats,get_custom_stats
var _stats
#export var max_hp : float = 10
#export var damage : float = 8
export var height : float = 1
export var spiky : bool = false
#export var move_speed : float = 1
#export var knockback_resistance : float = 0
#export var freeze_resistance : float = 0   
export var kill_resistance : bool = false
export(float, 0,1) var hp_scaling
export var drop_table : Resource



func set_custom_stats(val):
	_stats = val

func get_custom_stats():
	if _stats == null:
		_stats = StatSheetData.new()

	return _stats


func get_stat(stat):
	return _stats.get(stat)


func _ready():
	pass
