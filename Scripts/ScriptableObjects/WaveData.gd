tool
extends Resource
class_name WaveData

export(float) var minimum = 10.0
export(Array, Resource) var enemy_spawns setget set_custom_spawns
export(Array, Resource) var bosses setget set_custom_bosses
export(Array, Resource) var map_events setget set_custom_map_events

func set_custom_spawns(value):
	enemy_spawns.resize(value.size())
	enemy_spawns = value
	for i in enemy_spawns.size():
		if not enemy_spawns[i]:
			enemy_spawns[i] = EnemySpawnData.new()
			
			enemy_spawns[i].resource_name = "Spawn "+i.to_string()

func set_custom_bosses(value):
	bosses.resize(value.size())
	bosses = value
	for i in bosses.size():
		if not bosses[i]:
			bosses[i] = BossData.new()
			
			bosses[i].resource_name = "Boss "+i.to_string()

func set_custom_map_events(value):
	map_events.resize(value.size())
	map_events = value
	if  map_events.size() > 0:
		for i in map_events.size():
			if not map_events[i]:
				map_events[i] = MapEventData.new()
				MapEventData[i].resource_name = "Event "+i.to_string()
	pass



#export var enemy_spawns : EnemySpawnData[]
#export var bosses : BossData[]
#export var map_events : MapEventData[]

func _ready():
	pass
