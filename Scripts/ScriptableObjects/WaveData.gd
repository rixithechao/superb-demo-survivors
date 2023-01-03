tool
extends Resource
class_name WaveData

export(Array, Resource) var enemy_spawns setget set_custom_spawns
export(Array, Resource) var bosses setget set_custom_bosses
export(Array, Script) var map_events

func set_custom_spawns(value):
	enemy_spawns.resize(value.size())
	enemy_spawns = value
	for i in enemy_spawns.size():
		if not enemy_spawns[i]:
			enemy_spawns[i] = EnemySpawnData.new()
			
			enemy_spawns[i].resource_name = "Spawn"

func set_custom_bosses(value):
	bosses.resize(value.size())
	bosses = value
	for i in bosses.size():
		if not bosses[i]:
			bosses[i] = BossData.new()
			
			bosses[i].resource_name = "Boss"+i.to_string()



#export var enemy_spawns : EnemySpawnData[]
#export var bosses : BossData[]
#export var map_events : MapEventData[]

func _ready():
	pass
