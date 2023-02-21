extends VFX

export var value : int
export var is_crit : bool = false


func _ready():
	position.x += rand_range(-20,20)
	position.y += rand_range(-20,20)
	
	$Tween.interpolate_property($LocalPosition, "position",
		Vector2.ZERO, Vector2(rand_range(-20,20), -64), 0.5,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($LocalPosition/Label, "rect_rotation",
		0, rand_range(-10,10), 0.5,
		Tween.TRANS_QUAD, Tween.EASE_OUT)
	$Tween.interpolate_property($LocalPosition/Label, "modulate",
		Color.white, Color(1,1,1,0), 1,
		Tween.TRANS_QUAD, Tween.EASE_IN)
	$Tween.start()


func _process(_delta):
	if  SaveManager.settings.damage_numbers:
		$LocalPosition/Label.text = String(value) + ("!!!" if is_crit else "")
	else:
		$LocalPosition/Label.text = ""
