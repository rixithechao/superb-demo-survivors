extends Character

const HALT_SPEED = 0.1
const MAX_SPEED = 120.0

var direction_input = Vector2.ZERO
var direction = Vector2.ZERO

var current_diagonal = Vector2.ONE
var current_cardinal = Vector2(1,0)
var current_8dir = Vector2(1,0)

var last_facing_arrow = Vector2(1,0)
var lock_alpha = 0

export var movement_locked : bool = false



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

	# Other unsorted things
	$Graphic.draw_shadow = true
	direction_input = Vector2.ZERO

	if  not movement_locked:
		direction_input.x = Input.get_axis("ui_left", "ui_right")
		direction_input.y = Input.get_axis("ui_up","ui_down")
	
	if direction_input == Vector2.ZERO:
		direction.x = lerp(direction.x, 0, delta / HALT_SPEED)
		direction.y = lerp(direction.y, 0, delta / HALT_SPEED)
		$Graphic.state = PlayerGraphic.PlayerAnimState.IDLE
	else:
		direction.x = lerp(direction_input.x * MAX_SPEED, 0, delta)
		direction.y = lerp(direction_input.y * MAX_SPEED, 0, delta)
		$Graphic.state = PlayerGraphic.PlayerAnimState.WALK
	
	if  not Input.is_action_pressed("ui_select"):
		if  direction.x != 0:
			current_diagonal.x = sign(direction.x)
		if  direction.y != 0:
			current_diagonal.y = sign(direction.y)

		# If the player is moving in any direction
		if direction.length() > 0:
			
			# Store current 8-dir and cardinal facing for weapon aiming
			current_8dir.x = sign(direction.x)
			current_8dir.y = sign(direction.y)
			
			if  direction.x == 0  or  direction.y == 0:
				current_cardinal.x = sign(direction.x)
				current_cardinal.y = sign(direction.y)

			# Lerp the last facing arrow 
			last_facing_arrow = last_facing_arrow.slerp(direction.normalized(), 0.25*TimeManager.time_rate)

	lock_alpha = lerp(lock_alpha, (0 if not Input.is_action_pressed("ui_select") else 1), 0.25)

	$Graphic/AirOffset/Sprite.set_flip_h( current_diagonal.x == -1 )
	
	move_and_slide(direction*TimeManager.time_rate, Vector2.UP)
	
	#update_z()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		MenuManager.open("console")

	if Input.is_action_just_pressed("ui_pause"):
		MenuManager.open("pause")



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
