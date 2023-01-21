extends Node2D

export (float) var radius = 32
export (bool) var spawning = false
export (bool) var relative_to_player = false
export (float, 0, 120) var warning_seconds = 2
export (float, 0, 120) var despawn_seconds = 15
export (bool) var collides_with_other_enemies = true
export (PackedScene) var enemy_scene

var time : float = 0
var percent : float = 0
var started_spawning : bool = false



func configure_enemy(spawned):
	pass

func update_telegraphing():
	pass




func place():
	var pos = global_position
	WorldManager.add_map_event(self)
	global_position = pos

func spawn():
	var spawned = EnemyManager.spawn(enemy_scene, global_position)
	configure_enemy(spawned)
	spawned.spawn_type = 2
	spawned.collides_with_other_enemies = collides_with_other_enemies
	spawned.despawn_timer = despawn_seconds
	print("ENEMY SPAWNED VIA WARNING: ", spawned.name, ", ", spawned.position, ", ", spawned.get_parent())



func start():
	spawning = true
	$WarningSound.play()
	if  not relative_to_player:
		place()
	pass


func _ready():
	$Telegraph.modulate.a = 0
	pass

func _process(delta):
	if  not spawning  or  started_spawning:
		$Telegraph.modulate.a = 0
		return

	time += delta * TimeManager.time_rate
	if  warning_seconds > 0:
		percent = time/warning_seconds
	else:
		percent = 1
		
	$Telegraph/ProgressRotation/Progress.value = percent*100
	$AnimatedSprite.global_rotation_degrees = 0
	$Telegraph/ProgressRotation.global_rotation_degrees = 0
	$Telegraph.modulate.a = 1
	update_telegraphing()

	if  time >= warning_seconds  and  not started_spawning:
		
		if  relative_to_player:
			place()

		started_spawning = true
		$Telegraph.modulate = Color(1,1,1,0)
		$AnimationPlayer.play("Sequence_SpawnEnemy")
	pass


func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()
	pass # Replace with function body.
