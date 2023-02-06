extends EnemyWarning


export var speed : float = 1


var _temp_direction


func configure_enemy(spawned):
	var applied_angle = _temp_direction
	spawned.move_mode = 1
	spawned.move_speed = Vector2(speed,0).rotated(applied_angle)
	#print("VECTOR SPAWN CONFIGURED ENEMY: ", rad2deg(applied_angle), ", ", spawned.move_speed)




func on_start_spawning():
	_temp_direction = $Telegraph/Direction.global_rotation
	.on_start_spawning()

func update_telegraphing():
	var new_radius = lerp(radius, 1, fmod(4*percent, 1.0))
	var scale_factor = (radius/32)
	var scale_factor_percent = (new_radius/32)
	
	var new_scale = Vector2.ONE * scale_factor
	var new_scale_percent = Vector2.ONE * scale_factor_percent
	var new_width = 3.0 / scale_factor
	var new_width_percent = 3.0 / scale_factor_percent

	# Size
	$Telegraph/Direction/AntialiasedPolygon2D.scale = Vector2.ONE * scale_factor
	$Telegraph/Direction/AntialiasedLine2D.scale = new_scale
	$Telegraph/Direction/AntialiasedLine2D.width = new_width

	$Telegraph/Direction/Length/LeftLine.position.y = -radius
	$Telegraph/Direction/Length/RightLine.position.y = radius

	
	# Time indicators
	$Telegraph/Direction/TimeRing.scale = new_scale_percent
	$Telegraph/Direction/TimeRing.width = new_width_percent

	$Telegraph/Direction/Length/TimeLeftLine.position.y = -new_radius
	$Telegraph/Direction/Length/TimeRightLine.position.y = new_radius
	pass
