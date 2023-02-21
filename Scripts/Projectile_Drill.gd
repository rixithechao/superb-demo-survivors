extends Projectile


var top_speed


func _ready():
	._ready()
	top_speed = fire_speed
	pass


func on_hit_enemy(enemy_node):
	fire_speed = top_speed*0.25
	$LocalPos/Collision/CollisionShape2D.scale = Vector2.ONE * 1.25
	pass
