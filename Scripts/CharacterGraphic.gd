extends Node2D
class_name CharacterGraphic

export var tint : Color = Color(1,1,1,0)
export(Array, NodePath) var sprites
export(Array, NodePath) var flash_sprites

export var height : float = 0
export var shake_intensity : float = 0

export var draw_shadow : bool = true
export var override_height : bool = false
export var animate_while_paused : bool = false

var shake_offset = Vector2.ZERO
var shake_timer = 0



const SHAKE_FREQUENCY = 0.1




func clear_shake():
	$Tween.remove(self, "shake_intensity")

func clear_flash():
	$Tween.remove(self, "tint")

func clear_fade():
	$Tween.remove(self, "modulate")



func shake(intensity, seconds):
	clear_flash()
	$Tween.interpolate_property(self, "shake_intensity",
		intensity, 0, seconds,
		Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()

func flash(col, seconds):
	var col_transparent = Color(col.r, col.g, col.b, 0)

	clear_flash()
	$Tween.interpolate_property(self, "tint",
		col, col_transparent, seconds,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()

func fade(new_alpha, seconds):
	var col = self.modulate
	var col_final = Color(col.r, col.g, col.b, new_alpha)
	
	clear_fade()
	$Tween.interpolate_property(self, "modulate",
		col, col_final, seconds,
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()



func death_effects():
	pass



func _process(delta):

	# Shake
	if shake_intensity > 0:
		shake_timer += delta
		if  shake_timer > SHAKE_FREQUENCY:
			shake_timer = fmod(shake_timer, SHAKE_FREQUENCY)
			shake_offset = Vector2(rand_range(0, shake_intensity), 0).rotated(deg2rad(randi()%360))
			#print("SHAKING! ", shake_offset)
	else:
		shake_offset = Vector2.ZERO

	# Height
	if  not override_height:
		$AirOffset.position.y = -16*height

	# Shadow
	if  get_node_or_null("Shadow") != null:
		$Shadow.modulate.a = (1 if draw_shadow else 0)

	# Makeshift tinting
	for sprite in flash_sprites:
		var spr = get_node(sprite)
		spr.modulate = tint
		pass
	
	# Shaking, proper tinting/flashing
	for sprite in sprites:
		var spr = get_node(sprite)
		spr.offset = shake_offset
		
		#print(sprite)
		#get_node(sprite).material.set_shader_param("tint",tint)
		pass
	pass
