extends Character

const HALT_SPEED = 0.1
const MAX_SPEED = 120.0

var direction_input = Vector2.ZERO
var direction = Vector2.ZERO

var aim_input = Vector2.ZERO
var aim = Vector2.ZERO

var current_diagonal = Vector2.ONE
var current_cardinal = Vector2(1,0)
var current_8dir = Vector2(1,0)

var last_facing_arrow = Vector2(1,0)
var lock_alpha = 0

export var movement_locked : bool = false
export var aiming_locked : bool = false



func _ready():
	PlayerManager.instance = self
	PlayerManager.enemy_collision_area = $EnemyCollision
	
	if  CameraManager.instance.get_parent() != null:
		CameraManager.instance.get_parent().remove_child(CameraManager.instance)
	self.add_child(CameraManager.instance)
	
	start_sequence("Sequence_Spawn")
	

#func _draw():
#	draw_set_transform(Vector2(0,-2), 0, Vector2(1,0.5))
#	draw_circle(Vector2.ZERO, 12.0, Color(0, 0, 0, (0.5 if draw_shadow else 0.0)))


func damage_effects():
	$Graphic.shake(4,0.25)
	$Graphic.flash(Color(1,1,1,0.5), PlayerManager.mercy_seconds)
	$HurtSound.play()
	$HurtAccentSound.play()




func _process(delta):

	if  $Graphic == null:
		return

	if  TimeManager.is_paused:
		$Graphic.pause_mode = (Node.PAUSE_MODE_PROCESS if (not StageManager.started) else Node.PAUSE_MODE_INHERIT)
		return

	if PlayerManager.dead:
		$Graphic.draw_shadow = false
		z_index = VisualServer.CANVAS_ITEM_Z_MAX
		$Graphic.state = PlayerGraphic.PlayerAnimState.DIE
		return

	# Elevation
	._process(delta)

	# Stat multipliers
	var current_stats = PlayerManager.get_current_stats()
	var pickup_mod = current_stats[StatsManager.PICKUP]
	$ItemCollision.scale = Vector2.ONE * pickup_mod

	# Other unsorted things
	var strafe_input = (Input.is_action_pressed(InputManager.gameplay_controls.select)  or  Input.is_action_pressed(InputManager.gameplay_controls.strafe))
	var instant_aim = false


	$Graphic.draw_shadow = true
	direction_input = Vector2.ZERO

	if  not movement_locked:
		direction_input.x = Input.get_axis(InputManager.gameplay_controls.move_l, InputManager.gameplay_controls.move_r)
		direction_input.y = Input.get_axis(InputManager.gameplay_controls.move_u,InputManager.gameplay_controls.move_d)

	if  not aiming_locked:
		if  InputManager.current_control_scheme == InputManager.control_scheme.MKB:
			aim_input = get_local_mouse_position()
			instant_aim = true
		else:
			aim_input.x = Input.get_axis(InputManager.gameplay_controls.aim_l, InputManager.gameplay_controls.aim_r)
			aim_input.y = Input.get_axis(InputManager.gameplay_controls.aim_u,InputManager.gameplay_controls.aim_d)

	if  InputManager.current_control_scheme == InputManager.control_scheme.GAMEPAD:
		direction_input.x = clamp(direction_input.x * 2, -1,1)
		direction_input.y = clamp(direction_input.y * 2, -1,1)
		aim_input.x = clamp(aim_input.x * 2, -1,1)
		aim_input.y = clamp(aim_input.y * 2, -1,1)


	if  direction_input == Vector2.ZERO:
		direction.x = lerp(direction.x, 0, delta / HALT_SPEED)
		direction.y = lerp(direction.y, 0, delta / HALT_SPEED)
		$Graphic.state = PlayerGraphic.PlayerAnimState.IDLE
	else:
		direction.x = lerp(direction_input.x * MAX_SPEED, 0, delta)
		direction.y = lerp(direction_input.y * MAX_SPEED, 0, delta)
		$Graphic.state = PlayerGraphic.PlayerAnimState.WALK

	if  aim_input != Vector2.ZERO  and  not strafe_input:
		aim = aim_input.normalized()
		
		var abs_angle = abs(rad2deg(aim.angle()))
		
		var x_is_zero = abs_angle > 67.5  and  abs_angle < 112.5
		var y_is_zero = abs_angle < 22.5  or  abs_angle > 157.5

		var x_snapped_sign = (0.0 if x_is_zero else sign(aim.x))
		var y_snapped_sign = (0.0 if y_is_zero else sign(aim.y))

		if  not x_is_zero:
			current_diagonal.x = x_snapped_sign
		if  not y_is_zero:
			current_diagonal.y = y_snapped_sign

		# If the player is aiming in any direction
		if not (x_is_zero and y_is_zero):

			# Store current 8-dir and cardinal facing for weapon aiming
			current_8dir.x = x_snapped_sign
			current_8dir.y = y_snapped_sign

			if  x_is_zero  or  y_is_zero:
				current_cardinal.x = x_snapped_sign
				current_cardinal.y = y_snapped_sign

		#print ("CARDINAL: ", current_cardinal, "\n8DIR: ", current_8dir, "\nDIAGONAL: ", current_diagonal, "\nSNAPPED: (", x_snapped_sign,", ",y_snapped_sign, ")\nIS ZERO: (", x_is_zero, ", ", y_is_zero, ")\nANGLE: ", abs_angle, "\n")

		# Angle/lerp the last facing arrow
		if instant_aim:
			last_facing_arrow = aim.normalized()
		else:
			last_facing_arrow = last_facing_arrow.slerp(aim.normalized(), 0.25*TimeManager.time_rate)

	lock_alpha = lerp(lock_alpha, (0 if not strafe_input else 1), 0.25)

	$Graphic.mirror = ( current_diagonal.x == -1 )
	
	move_and_slide(direction*TimeManager.time_rate*current_stats[StatsManager.MOVEMENT], Vector2.UP)
	
	var half_size = WorldManager.instance.map_size
	
	position.x = clamp(position.x, -32 * (half_size.x - 1), 32 * (half_size.x - 1))
	position.y = clamp(position.y, -32 * (half_size.y - 1), 32 * (half_size.y - 1))
	#update_z()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		MenuManager.queue("console")

	if Input.is_action_just_pressed(InputManager.gameplay_controls.pause):
		MenuManager.queue("pause")



func restart():
	position = Vector2.ZERO
	direction = Vector2.ZERO
	$Graphic.state = PlayerGraphic.PlayerAnimState.IDLE
	$Graphic.tint = Color(1,1,1,0)

func set_anim_state(state : int):
	$Graphic.state = state
	#$Graphic/AnimationPlayer.play(sequence_name)

func start_sequence(sequence_name : String):
	$SequenceAnimPlayer.play(sequence_name)
