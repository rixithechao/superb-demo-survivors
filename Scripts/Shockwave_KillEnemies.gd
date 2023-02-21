extends Shockwave

export var kill_bosses : bool = false
export var prevent_drops : bool = false

func on_object_touched(object_node):
	if  not object_node.is_final_boss  and  not object_node.data.kill_resistance  and  (kill_bosses  or  object_node.spawn_type != EnemyCharacter.EnemySpawnType.BOSS):
		object_node.die(prevent_drops)
