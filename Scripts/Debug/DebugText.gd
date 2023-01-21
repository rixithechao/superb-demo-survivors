extends Label


func _process(_delta):
	#print("ALL ENEMIES=", EnemyManager.all, "\n\nALL PROJECTILES=", ProjectileManager.all)
	text = String(TimeManager.pauses.size()) + " pauses\n\n" + String(ProjectileManager.count) + " projectiles\n\n" + String(EnemyManager.count) + " enemies\n" + String(StageManager.spawn_data)
	pass
