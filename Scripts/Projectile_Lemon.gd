extends Projectile


func _ready():
	._ready()
	
	if  randf() <= 0.05:
		$LocalPos/Collision/Graphic/Sprite.frame += 1
