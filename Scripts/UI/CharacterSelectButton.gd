extends Button

export (Resource) var data

var char_added = false
var idx = 0
var gfx


signal char_selected
signal char_hovered


func _process(_delta):
	if  data != null  and  not char_added:
		char_added = true
		gfx = data.gfx_prefab.instance()
		$PlayerGraphicPosition.add_child(gfx)
		gfx.position = Vector2.ZERO

		$Label.text = data.name
	
	if  char_added:
		gfx.state = (PlayerGraphic.PlayerAnimState.WALK if (get_focus_owner() == self) else PlayerGraphic.PlayerAnimState.IDLE)
		gfx.mercy_blinking = false



func _on_Button__Character_pressed():
	emit_signal("char_selected", self)


func _on_Button__Character_mouse_entered():
	$CursorSound.play()
	self.grab_focus()


func _on_Button__Character_focus_entered():
	$CursorSound.play()
	emit_signal("char_hovered", self)
	pass # Replace with function body.
