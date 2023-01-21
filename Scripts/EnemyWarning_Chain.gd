extends Node2D



export (NodePath) var warning_stamp
export (bool) var orient_to_path = false
export (float, 0.1, 1000) var gap = 96
export (float, 0, 200) var duration = 1

var stamp_node



func _ready():
	$Path2D.self_modulate.a = 0
	stamp_node = get_node(warning_stamp)
	var spawning = stamp_node.spawning
	stamp_node.spawning = false
	
	if spawning:
		start()





func start():
	var path = $Path2D
	var follower = $Path2D/PathFollow2D
	var length = path.curve.get_baked_length()
	var count = round(length/gap)
	var actual_gap = length/count

	var time_gap = 0
	if duration > 0:
		time_gap = duration/count


	# configure the path follower
	follower.rotate = orient_to_path

	# spawn the points
	for i in count:
		follower.offset = actual_gap*i


		# instantiate point warning and copy over properties
		var spawned

		if  stamp_node.is_in_group("enemyWarning_point"):
			spawned = EnemyManager.spawner_point.instance()
		else:
			spawned = EnemyManager.spawner_vector.instance()
			spawned.speed = stamp_node.speed
			spawned.get_node("Telegraph/Direction/Length").scale.x = stamp_node.get_node("Telegraph/Direction/Length").scale.x

		spawned.radius = stamp_node.radius
		spawned.relative_to_player = stamp_node.relative_to_player
		spawned.warning_seconds = stamp_node.warning_seconds
		spawned.despawn_seconds = stamp_node.despawn_seconds
		spawned.collides_with_other_enemies = stamp_node.collides_with_other_enemies
		spawned.enemy_scene = stamp_node.enemy_scene


		# Place in the map event and apply the transformation
		get_parent().add_child(spawned)
		spawned.global_position = follower.global_position
		if  orient_to_path:
			spawned.get_node("Telegraph").global_rotation = follower.global_rotation + stamp_node.rotation

		# Start the spawner
		spawned.start()

		# Yield if there is a time gap
		if time_gap > 0:
			yield(get_tree().create_timer(time_gap), "timeout")
	
	pass
