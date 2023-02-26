extends "res://Scripts/UI/Menu.gd"


var current_logged_idx = -1
var temp_text = ""


func browse_logged(dir):
	if  current_logged_idx == -1:
		temp_text = $LineEdit.text
	
	current_logged_idx = int(clamp(current_logged_idx+dir, -1, CommandConsoleManager.logged_commands.size()-1))
	
	if  current_logged_idx > -1:
		$LineEdit.text = CommandConsoleManager.logged_commands[CommandConsoleManager.logged_commands.size()-1-current_logged_idx]
	else:
		$LineEdit.text = temp_text



func _on_new_log_entry(text):
	$Log.text = $Log.text + "\n" + text
	
func _on_other_menu():
	close()



func on_close():
	TimeManager.remove_pause("cheating")




func _ready():
	CommandConsoleManager.connect("new_log_entry", self, "_on_new_log_entry")
	CommandConsoleManager.connect("triggered_new_menu", self, "_on_other_menu")
	
	TimeManager.add_pause("cheating")
	$LineEdit.text = ""
	$Log.text = CommandConsoleManager.get_log_as_string()
	$LineEdit.grab_focus()
	pass



func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		CommandConsoleManager.run_command($LineEdit.text)
		$LineEdit.text = ""
		current_logged_idx = -1
		pass
	
	elif Input.is_action_just_pressed("ui_up"):
		browse_logged(1)
	elif Input.is_action_just_pressed("ui_down"):
		browse_logged(-1)

	elif Input.is_action_just_pressed("ui_focus_next"):
		close()
		pass
