extends "res://Scripts/UI/Menu.gd"

var speed = 50
var fast_mult = 6

func _process(delta):
	var speeding = (not Input.is_action_pressed("ui_cancel") and Input.is_action_pressed("ui_anykey"))

	var credits_label = $RichTextLabel
	
	if  credits_label.rect_position.y + credits_label.rect_size.y > -20:
		credits_label.rect_position -= Vector2(0,speed * delta * (fast_mult if speeding else 1))
	else:
		close()
