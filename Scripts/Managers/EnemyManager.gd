extends "res://Scripts/ManagerForGroupedObjects.gd"


var spawner_point = preload("res://Prefabs/Enemy Warnings/Prefab_EnemyWarning_Point.tscn")
var spawner_vector = preload("res://Prefabs/Enemy Warnings/Prefab_EnemyWarning_Vector.tscn")



#var data_cache = {}

func get_group_name():
	return "enemy"



func spawn(spawn_data, position = null):
	
	# Spawn from PackedResource
	#var spawn_res = data_cache[spawn_data]
	var spawned = spawn_data.instance()
	#print ("ENEMY SPAWNED AT ", spawned.position)

	# If position isn't specified, place at the edges of the spawn region
	if position != null:
		spawned.global_position = position
	else:
		var extents = CameraManager.spawn_area.get_node("SpawnShape").shape.extents
		var player_pos = PlayerManager.instance.position
		
		var rand_side = pow(-1, randi() % 2)
		if randi() & 1:
			spawned.position = player_pos + Vector2(
				rand_side*extents.x,
				rand_range(-extents.y, extents.y)
			)
		else:
			spawned.position = player_pos + Vector2(
				rand_range(-extents.x, extents.x),
				rand_side*extents.y
			)

	WorldManager.add_object(spawned)

	#if  PlayerManager.instance != null  and  spawned.position != null:
	#	print ("ENEMY MOVED TO ", spawned.position, ", dist to player = ", spawned.position - PlayerManager.instance.position)
	#else:
	#	print ("ENEMY MOVED TO ", spawned.position)
	

	#print("Enemy spawn result:\n", spawn_data, "\n", spawned, "\n")
	return spawned

func spawn_boss(boss_data, position = null):
	var spawned = spawn(boss_data.enemy, position)
	spawned.spawn_type = 1
	spawned.treasure = boss_data.treasure
	
	return spawned



func init_stage_enemies():
	#data_cache.clear()
	#for wave in StageManager.current_stage_data.waves:
	#	for spawn in wave.enemy_spawns:
	#		for enemy in spawn.enemies:
	#			data_cache[enemy] = enemy
	pass


func _ready():
	pass
