extends Projectile


export var turns_left : int = 1

var turn_delay
var turns_remaining


func _ready():
	HarmableManager.connect("take_hit", self, "on_hit")
	turn_delay = 0
	turns_remaining = int(turns_left)
	
	var rotation = 0
	if weapon_data.get_current_level() < 8:
		rotation = 180*volley_index
	else:
		rotation = 90*volley_index
	
	._ready()
	
	var cardinal = PlayerManager.instance.current_cardinal.normalized()
	fire_speed = cardinal.rotated(deg2rad(rotation)) * get_speed_mult()
	
func on_hit(signal_data):
	if signal_data.projectile == self:
		if turn_delay <= 0:
			if  turns_remaining > 0:
				turns_remaining -= 1
				$LocalPos/Collision/Graphic/Sprite.frame = max(0, 3-turns_remaining)
				$RedirectSound.play()
				fire_speed = fire_speed.rotated(((randi()%2)-0.5)*PI)
				turn_delay = 0.2
			else:
				destroy()

func custom_movement(delta):
	turn_delay -= delta
		
	if false:
		if  turns_remaining > 0:
			var current_speed = fire_speed * 1.0
			#print ("CUBE SPEED: ", abs(current_speed.y))

			if  Input.is_action_just_pressed(InputManager.gameplay_controls.move_u)  and  abs(fire_speed.y) <= 0.01:
				fire_speed = Vector2(0, -1)

			if  Input.is_action_just_pressed(InputManager.gameplay_controls.move_d)  and  abs(fire_speed.y) <= 0.01:
				fire_speed = Vector2(0, 1)

			if  Input.is_action_just_pressed(InputManager.gameplay_controls.move_l)  and  abs(fire_speed.x) <= 0.01:
				fire_speed = Vector2(-1, 0)

			if  Input.is_action_just_pressed(InputManager.gameplay_controls.move_r)  and  abs(fire_speed.x) <= 0.01:
				fire_speed = Vector2(1, 0)

			# speed has changed
			if  fire_speed != current_speed:
				turns_left -= 1
				fire_speed *= get_speed_mult()
				$LocalPos/Collision/Graphic/Sprite.frame = max(0, 3-turns_left)
				$RedirectSound.play()

	.custom_movement(delta)
