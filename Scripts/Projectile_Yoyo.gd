extends Projectile

var time = 0
var center
var start_rot = 0

const RADIUS = 32
const SPEED = 2


func _ready():
	._ready()
	time = 0
	start_rot = deg2rad(rand_range(-aim_spread, aim_spread))
	center = $LocalPos.position
	pass


func custom_movement(delta):
	
	var time_passed = TimeManager.time_rate * delta
	time = time + time_passed

	var spd = SPEED * get_speed_mult()
	
	$LocalPos.position.x = RADIUS * time * spd * cos(time * spd + start_rot)
	$LocalPos.position.y = RADIUS * time * spd * sin(time * spd + start_rot)
