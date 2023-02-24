extends Projectile



var rot_dir

const ROT_DEGREES = 360


func _ready():
	._ready()
	rot_dir = 1
	pass


func custom_movement(delta):
	fire_speed = fire_speed.rotated(deg2rad(ROT_DEGREES*rot_dir*delta))*1.015
	rot_dir *= 0.995
	
	.custom_movement(delta)
