extends Projectile


export var homing_radius = 160

var rot_dir
var enemy_target_node

const ROT_DEGREES = 360


func _ready():
	._ready()
	rot_dir = pow(-1, randi() % 2)
	pass


func _on_TurnTimer_timeout():
	
	# Refresh the target
	if  is_instance_valid(enemy_target_node):
		return
	else:
		var closest_enemy = HarmableManager.get_nearest($LocalPos)
		if  closest_enemy != null  and  closest_enemy.distance <= homing_radius:
			enemy_target_node = closest_enemy.node


	# If there is a target, fly toward it
	if  is_instance_valid(enemy_target_node):
		var dir_to_enemy = enemy_target_node.global_position - $LocalPos.global_position
		
		var angle_to_enemy = fire_speed.angle_to(dir_to_enemy)
		var angle_sign = sign(angle_to_enemy)
		if  angle_sign == 0:
			angle_sign = pow(-1, randi() % 2)

		rot_dir = angle_sign

	# Otherwise, just zigzag
	else:
		rot_dir *= -1


	# Restart the timer
	$TurnTimer.start(rand_range(0.2,0.4))




func custom_movement(delta):
	fire_speed = fire_speed.rotated(deg2rad(ROT_DEGREES*rot_dir*delta))
	
	$LocalPos.scale.x = sign(fire_speed.x)
	.custom_movement(delta)
