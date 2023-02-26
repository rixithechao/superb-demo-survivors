extends Projectile


var top_speed
var sound_volume


func _ready():
	._ready()
	top_speed = fire_speed
	sound_volume = $AudioStreamPlayer.volume_db
	
	if fire_direction.x > 0.1:
		$LocalPos/Collision/Graphic/AnimationPlayer.play("Right")
	elif fire_direction.x < -0.1:
		$LocalPos/Collision/Graphic/AnimationPlayer.play("Left")
	elif fire_direction.y < -0.1:
		$LocalPos/Collision/Graphic/AnimationPlayer.play("Up")
	else:
		$LocalPos/Collision/Graphic/AnimationPlayer.play("Down")
	
	$AudioStreamPlayer.play()
	pass

func _process(delta):
	if $Duration.time_left < 1:
		$AudioStreamPlayer.volume_db = lerp(-20, sound_volume, $Duration.time_left)
	._process(delta)
	pass

func on_hit_enemy(enemy_node):
	fire_speed = top_speed*0.125
	$LocalPos/Collision/CollisionShape2D.scale = Vector2.ONE * 1.25
	pass
