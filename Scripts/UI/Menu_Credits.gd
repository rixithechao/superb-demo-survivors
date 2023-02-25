extends "res://Scripts/UI/Menu.gd"

var speed = 50
var fast_mult = 6

var credits_label

onready var file = 'res://credits.txt'


func _populate_credits():
	var generated_text = "[center]"
	
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var full_line
		var line = f.get_line()

		if  line.begins_with("= "):
			line.erase(0,2)
			full_line = "[font=res://Fonts//DynFont_Subheaders.tres]" + line + "[/font]"
		else:
			full_line = line

		generated_text += "\n\n" + full_line

	f.close()
	
	generated_text += "\n[/center]"
	credits_label.bbcode_text = generated_text
	
	return


func _process(delta):
	var speeding = (not Input.is_action_pressed("ui_cancel") and Input.is_action_pressed("ui_anykey"))

	if  credits_label == null:
		credits_label = $RichTextLabel
		_populate_credits()
	
	if  credits_label.rect_position.y + credits_label.rect_size.y > -20:
		credits_label.rect_position -= Vector2(0,speed * delta * (fast_mult if speeding else 1))
	else:
		close()
