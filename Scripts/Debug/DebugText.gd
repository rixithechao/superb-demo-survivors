extends Label


func _process(_delta):
	#print("ALL ENEMIES=", EnemyManager.all, "\n\nALL PROJECTILES=", ProjectileManager.all)
	text = "Revive cost: " + String(PlayerManager.get_revive_cost()) + "\n\nCurrent wave = " + String(StageManager.current_wave) + "\n\n" + String(BreakableManager.count) + " breakables\n" + String(LandmarkManager.count) + " landmarks\n" + String(TimeManager.pauses.size()) + " pauses\n" +  String(ProjectileManager.count) + " projectiles\n" + String(EnemyManager.count) + " enemies\n\n" + String(StageManager.spawn_data) + "\n\n" + String(PlayerManager.equipment_nodes)
	pass
