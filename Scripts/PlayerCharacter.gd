extends KinematicBody2D

const HALT_SPEED = 0.1
const MAX_SPEED = 160.0

var direction_input = Vector2.ZERO
var direction = Vector2.ZERO
var last_facing = Vector2.ONE


func _ready():
	PlayerManager.instance = self
	$Graphic/AnimationTree.active = true

func _draw():
	draw_set_transform(Vector2(0,-2), 0, Vector2(1,0.5))
	draw_circle(Vector2.ZERO, 12.0, Color(0.0,0.0,0.0,0.5))


func _process(delta):
	$HPBar.value = PlayerManager.hp
	$HPBar.max_value = PlayerManager.hp_max
	
	direction_input = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left"):
		direction_input.x = -1
		#$Sprite.flip_h = true

	if Input.is_action_pressed("ui_right"):
		direction_input.x = 1
		#$Sprite.flip_h = false
	
	if Input.is_action_pressed("ui_up"):
		direction_input.y = -1
		#$Sprite.flip_h = true

	if Input.is_action_pressed("ui_down"):
		direction_input.y = 1
		#$Sprite.flip_h = false
	
	if direction_input == Vector2.ZERO:
		direction.x = lerp(direction.x, 0, delta / HALT_SPEED)
		direction.y = lerp(direction.y, 0, delta / HALT_SPEED)
		$Graphic/AnimationTree.set("parameters/movement/current", 0)
	else:
		direction.x = lerp(direction_input.x * MAX_SPEED, 0, delta)
		direction.y = lerp(direction_input.y * MAX_SPEED, 0, delta)
		$Graphic/AnimationTree.set("parameters/movement/current", 1)
	
	if  direction.x != 0:
		last_facing.x = sign(direction.x)
	if  direction.y != 0:
		last_facing.y = sign(direction.y)

		
	$Graphic/Sprite.set_flip_h( last_facing.x == -1 )
	
	move_and_slide(direction*TimeManager.time_rate, Vector2.UP)
	
	self.z_index = self.position.y
