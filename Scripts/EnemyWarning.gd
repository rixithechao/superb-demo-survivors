extends Warning
class_name EnemyWarning

export (float) var radius = 32.0
export (bool) var relative_to_player = false
export (float, 0.0, 120.0) var despawn_seconds = 15.0
export (bool) var collides_with_other_enemies = true
export (PackedScene) var enemy_scene
export (bool) var spawn_effects = true



func configure_enemy(_spawned):
	pass




func place():
	var pos = global_position
	WorldManager.add_map_event(self)
	global_position = pos

func spawn():
	if  enemy_scene != null:
		var spawned = EnemyManager.spawn(enemy_scene, global_position)
		configure_enemy(spawned)
		spawned.spawn_type = 2
		spawned.collides_with_other_enemies = collides_with_other_enemies
		spawned.despawn_timer = despawn_seconds
	#print("ENEMY SPAWNED VIA WARNING: ", spawned.name, ", ", spawned.position, ", ", spawned.get_parent())



func start():
	if  not relative_to_player:
		place()
	.start()





func _process(delta):
	._process(delta)
	$AnimatedSprite.global_rotation_degrees = 0


func on_start_spawning():
	if  relative_to_player:
		place()
	
	if  spawn_effects  and  enemy_scene != null:
		$AnimationPlayer.play("Sequence_SpawnEnemy")
	else:
		spawn()
		self.queue_free()


func _on_AnimationPlayer_animation_finished(_anim_name):
	self.queue_free()
	pass # Replace with function body.
