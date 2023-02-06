extends Button


func _process(_delta):
	if  has_focus()  and  Input.is_action_just_pressed("ui_select"):
		emit_signal("pressed")
	pass
