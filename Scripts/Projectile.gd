extends Node
class_name Projectile


enum ProjectileOrientType {
	NONE,
	FLIP_HORIZONTAL,
	FLIP_VERTICAL,
	FLIP_4DIR,
	ROTATE,
	DIRECTIONAL_FRAMES
}

enum ProjectileAlternateType {
	NONE,
	FLIP_X,
	FLIP_Y
}

enum ProjectileTargetType {
	PLAYER,
	ENEMY_RANDOM,
	ENEMY_NEAREST
}

enum ProjectileAimType {
	NONE,
	PLAYER_HORIZONTAL,
	PLAYER_VERTICAL,
	PLAYER_DIAGONAL,
	PLAYER_CARDINAL,
	PLAYER_8DIR,
	PLAYER_360,
	TO_PLAYER,
	TO_ENEMY_RANDOM,
	TO_ENEMY_NEAREST,
	TO_WALL_NEAREST
}

enum ProjectileSpreadType {
	RANDOM,
	FAN,
	#SINE
}


var weapon_data : Resource
export(ProjectileOrientType) var orientation_mode
export var relative_position = true
export var spawn_radius : float = 0
export(ProjectileTargetType) var target_type = ProjectileTargetType.PLAYER
export(ProjectileAimType) var aim_type = ProjectileAimType.PLAYER_HORIZONTAL
export(ProjectileAlternateType) var alternate_type = ProjectileAlternateType.NONE
export(ProjectileSpreadType) var spread_type = ProjectileSpreadType.RANDOM
export var aim_spread : float = 0
export var speed : float = 1
export var acceleration : Vector3
export var acceleration_is_relative : bool = true
export var deceleration : float
export (PackedScene) var spawn_vfx
export (PackedScene) var death_vfx

var fire_direction : Vector2
var fire_speed : Vector2
var target_node

var target_offset = Vector2.ZERO

var enemies_pierced = 0

var volley_index = 0
var volley_max = 9999




func on_hit_enemy(enemy_node):
	pass

func custom_movement(delta):
	var accel_applied = Vector2(acceleration.x, acceleration.y)
	if acceleration_is_relative:
		accel_applied = accel_applied.rotated(fire_direction.angle())

	var decel_applied = fire_speed.normalized() * deceleration

	var time_passed = TimeManager.time_rate * delta

	fire_speed += (accel_applied - decel_applied) * time_passed
	$LocalPos.position += fire_speed * time_passed * 100

func get_speed_mult():
	return speed * weapon_data.get_stat_current(StatsManager.SPEED)




func _ready():
	
	# Scale based on area stat
	self.scale = Vector2.ONE * weapon_data.get_stat_current(StatsManager.AREA)
	
	# Spawn at the target
	match target_type:
		ProjectileTargetType.PLAYER:
			target_node = PlayerManager.instance
			target_offset.y = -24

		ProjectileTargetType.ENEMY_RANDOM:
			target_node = HarmableManager.get_random()

		ProjectileTargetType.ENEMY_NEAREST:
			target_node = HarmableManager.get_nearest().node

	#if not relative_position:
	self.position = target_node.position + target_offset


	# Fire
	fire_direction = Vector2.ZERO
	var enemy_node
	
	match aim_type:
		ProjectileAimType.PLAYER_HORIZONTAL:
			fire_direction = Vector2(PlayerManager.instance.current_diagonal.x, 0)
		
		ProjectileAimType.PLAYER_VERTICAL:
			fire_direction = Vector2(0, PlayerManager.instance.current_diagonal.y)
		
		ProjectileAimType.PLAYER_DIAGONAL:
			fire_direction = PlayerManager.instance.current_diagonal
		
		ProjectileAimType.PLAYER_CARDINAL:
			fire_direction = PlayerManager.instance.current_cardinal
		
		ProjectileAimType.PLAYER_8DIR:
			fire_direction = PlayerManager.instance.current_8dir

		ProjectileAimType.PLAYER_360:
			fire_direction = PlayerManager.instance.last_facing_arrow

		ProjectileAimType.TO_PLAYER:
			enemy_node = PlayerManager.instance
		
		ProjectileAimType.TO_ENEMY_NEAREST:
			enemy_node = HarmableManager.get_nearest().node
			if enemy_node == null:
				fire_direction = PlayerManager.instance.last_facing_arrow

		ProjectileAimType.TO_ENEMY_RANDOM:
			enemy_node = HarmableManager.get_random()
			if enemy_node == null:
				fire_direction = Vector2(1,0).rotated(rand_range(-180,180))


	if enemy_node != null:
		fire_direction = enemy_node.position - self.position

	var normalized_dir = fire_direction.normalized()
	self.position = self.position + normalized_dir * spawn_radius
	
	var spread_add = rand_range(-aim_spread, aim_spread)
	if  spread_type == ProjectileSpreadType.FAN:
		if volley_max > 1:
			spread_add = lerp(-aim_spread, aim_spread, volley_index/(volley_max-1))
		else:
			spread_add = 0
	
	fire_speed = normalized_dir.rotated(deg2rad(spread_add)) * get_speed_mult()  #*PlayerManager.get_weapon_speed()
	
	$Duration.wait_time = weapon_data.get_stat_current(StatsManager.DURATION)
	$Duration.start()
	
	if  self.has_node("AnimationPlayer"):
		$AnimationPlayer.play("default")

	elif  self.has_node("LocalPos/Graphic/AnimatedSprite"):
		$LocalPos/Collision/Graphic/AnimatedSprite.playing = true
	
	match orientation_mode:
		ProjectileOrientType.FLIP_HORIZONTAL:
			$LocalPos.scale.x = PlayerManager.instance.last_facing.x

		ProjectileOrientType.FLIP_VERTICAL:
			$LocalPos.scale.y = PlayerManager.instance.last_facing.y

		ProjectileOrientType.FLIP_4DIR:
			$LocalPos.scale.x = PlayerManager.instance.last_facing.x
			$LocalPos.scale.y = PlayerManager.instance.last_facing.y

		ProjectileOrientType.ROTATE:
			$LocalPos.rotation_degrees = rad2deg(fire_speed.angle())


	# Alternating swings and such
	match alternate_type:
		ProjectileAlternateType.FLIP_X:
			$LocalPos.scale.x *= pow(-1, volley_index)
		ProjectileAlternateType.FLIP_Y:
			$LocalPos.scale.y *= pow(-1, volley_index)

	# Spawn vfx
	if  spawn_vfx != null:
		VFXManager.spawn(spawn_vfx, $LocalPos.global_position)



func destroy():
	if  death_vfx != null:
		VFXManager.spawn(death_vfx, $LocalPos.global_position)
	self.queue_free()



func _process(delta):
	if  relative_position and target_node != null:
		self.position = target_node.position + target_offset
	
	if weapon_data.pierce_type == WeaponData.WeaponPierceType.LIMITED  and  enemies_pierced > weapon_data.get_stat_current(StatsManager.PIERCE):
		destroy()

	custom_movement(delta)



func _on_Duration_timeout():
	destroy()
	pass # Replace with function body.


func _on_Collision_body_entered(body):
	if body.is_in_group("harmable"):
		body.hit_by_projectile(self)
		on_hit_enemy(body)
		pass # Replace with function body.
