extends Projectile

var time = 0
var center
var start_rot = 0
var sound_volume
var trail_counter = 0
var trail_length = 0

const RADIUS = 20
const SPEED = 2
const TRAIL_RES = 0
const MAX_TRAIL_LENGTH = 256

var trail_points = []

func _ready():
	._ready()
	time = 0
	start_rot = deg2rad(rand_range(-aim_spread, aim_spread))
	center = $LocalPos.position
	sound_volume = $AudioStreamPlayer.volume_db
	
	$AudioStreamPlayer.play()
	pass

	

func _process(delta):
	if $Duration.time_left < 1:
		$AudioStreamPlayer.volume_db = lerp(-20, sound_volume, $Duration.time_left)
		$Trail.default_color.a = lerp(0, 0.5, $Duration.time_left)
		
	._process(delta)
			
	if trail_counter <= 0:
		var new_pt = $LocalPos.global_position
		if trail_points.size() >= 1:
			trail_length += trail_points.back().distance_to(new_pt)

			while trail_length > MAX_TRAIL_LENGTH:
				var start = trail_points.pop_front()
				if trail_points.size() > 1:
					trail_length -= start.distance_to(trail_points.front())
				else:
					trail_length = 0
				
		else:
			trail_length = 0
			
		trail_points.append(new_pt)
		
		trail_counter = TRAIL_RES
	else:
		trail_counter -= delta
	pass

func custom_movement(delta):
	
	var time_passed = TimeManager.time_rate * delta
	time = time + time_passed

	var spd = SPEED * sqrt(get_speed_mult())
	
	$LocalPos.position.x = RADIUS * time * spd * cos(time * spd + start_rot)
	$LocalPos.position.y = RADIUS * time * spd * sin(time * spd + start_rot)
	
	$Thread.set_point_position(0, $LocalPos.get_parent().to_local(PlayerManager.instance.global_position + Vector2(0,-16)))
	$Thread.set_point_position(1, $LocalPos.get_parent().to_local($LocalPos.global_position))
	
	while trail_points.size() < $Trail.get_point_count():
		$Trail.remove_point($Trail.get_point_count()-1)
	
	for idx in trail_points.size():
		var pt = $LocalPos.get_parent().to_local(trail_points[idx])
		if idx >= $Trail.points.size():
			$Trail.add_point(pt)
		else:
			$Trail.set_point_position(idx, pt)
	
		
