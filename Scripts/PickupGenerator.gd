extends Node2D


export var pickup_to_spawn : PackedScene

var spawned


func _on_Timer_timeout():
	if  PlayerManager.instance == null:
		return
	var dist = PlayerManager.instance.global_position - self.global_position
	
	if  dist.length() > 128  and  (spawned == null  or  not is_instance_valid(spawned)):
		spawned = StageManager.spawn_pickup(pickup_to_spawn, self.position)
