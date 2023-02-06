extends EnemyWarning


func configure_enemy(_spawned):
	pass
	
func update_telegraphing():
	var percent_radius = lerp(radius, 0.5, fmod(4*percent, 1.0))
	
	$Telegraph/SpawnRadius.size = Vector2.ONE * radius * 2
	$Telegraph/TimeRing.size = Vector2.ONE * percent_radius * 2
	pass
