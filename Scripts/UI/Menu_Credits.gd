extends "res://Scripts/UI/Menu.gd"

var speed = 50
var fast_mult = 6

var credits_label
var column_regex = RegEx.new()

onready var file = 'res://credits.txt'

func _parse_line(line):	
	if  line.begins_with("= "):
		line.erase(0,2)
		return "[font=res://Fonts//DynFont_Subheaders.tres]" + line + "[/font]"
	elif line == ">>":
		return 1
	else:
		var result = column_regex.search(line)
		if result:
			return int(result.get_string(1))
		return line
	pass

func _populate_credits():
	var generated_text = "[center]"
	
	column_regex.compile("^\\<(\\d+)\\<$")
	var f = File.new()
	f.open(file, File.READ)
	var index = 1
	var columns = 1
	while not f.eof_reached(): # iterate through all lines until the end of file is reached
		var line = f.get_line()
		var full_line = _parse_line(line)
		if typeof(full_line) == TYPE_INT:
			columns = full_line

		if full_line != null and typeof(full_line) != TYPE_INT:
			generated_text += "\n\n" + full_line
			var n = columns - 1
			for i in n:
				var last_pos = f.get_position()
				var next = _parse_line(f.get_line())
				if next == null or typeof(next) == TYPE_INT:
					f.seek(last_pos)
					break
				else:
					generated_text += "\t" + next
			

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
