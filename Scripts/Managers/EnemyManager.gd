extends "res://Scripts/ManagerForGroupedObjects.gd"


var spawner_point = preload("res://Prefabs/Enemy Warnings/Prefab_EnemyWarning_Point.tscn")
var spawner_vector = preload("res://Prefabs/Enemy Warnings/Prefab_EnemyWarning_Vector.tscn")

var pre_final_shockwave = preload("res://Prefabs/Shockwaves/Prefab_Shockwave_FinalBossPreWipe.tscn")

var kills = 0


signal change_kills


#var data_cache = {}

func get_group_name():
	return "enemy"



func add_kill():
	kills += 1
	emit_signal("change_kills")


func clear_all_enemies():
	var inst = pre_final_shockwave.instance()
	WorldManager.add_object(inst)
	inst.global_position = PlayerManager.instance.global_position



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
	spawned.is_final_boss = boss_data.final
	
	if  boss_data.final:
		clear_all_enemies()
		
		var boss_music = StageManager.current_stage_data.boss_music_data
		if  boss_music == null:
			boss_music = MusicManager.TRACKS.BOSS
		MusicManager.play(boss_music)
	
	return spawned



func init_stage_enemies():
	#data_cache.clear()
	#for wave in StageManager.current_stage_data.waves:
	#	for spawn in wave.enemy_spawns:
	#		for enemy in spawn.enemies:
	#			data_cache[enemy] = enemy
	pass


func kill_all():
	for enemy in get_all():
		enemy.die()



func _ready():
	pass
