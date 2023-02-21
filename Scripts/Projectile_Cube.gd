extends Projectile


export var turns_left : int = 1


func _ready():
	._ready()



func custom_movement(delta):

	if  turns_left > 0:
		var current_speed = fire_speed * 1.0
		#print ("CUBE SPEED: ", abs(current_speed.y))

		if  Input.is_action_just_pressed("ui_up")  and  abs(fire_speed.y) <= 0.01:
			fire_speed = Vector2(0, -1)

		if  Input.is_action_just_pressed("ui_down")  and  abs(fire_speed.y) <= 0.01:
			fire_speed = Vector2(0, 1)

		if  Input.is_action_just_pressed("ui_left")  and  abs(fire_speed.x) <= 0.01:
			fire_speed = Vector2(-1, 0)

		if  Input.is_action_just_pressed("ui_right")  and  abs(fire_speed.x) <= 0.01:
			fire_speed = Vector2(1, 0)

		# speed has changed
		if  fire_speed != current_speed:
			turns_left -= 1
			fire_speed *= get_speed_mult()
			$LocalPos/Collision/Graphic/Sprite.frame = max(0, 3-turns_left)

	.custom_movement(delta)
