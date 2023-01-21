extends "res://Scripts/UI/Menu.gd"


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
		pass

	elif Input.is_action_just_pressed("ui_focus_next"):
		close()
		pass
