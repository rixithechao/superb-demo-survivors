extends Node

var logged_strings = []
var regex = RegEx.new()


signal new_log_entry
signal triggered_new_menu



func log_text(text):
	logged_strings.append(text)
	emit_signal("new_log_entry", text)


func get_log_as_string():
	var combined = ""
	for entry in logged_strings:
		combined = entry + "\n" + combined
	
	return combined


func run_command(text):
	var results = []
	for result in regex.search_all(text):
		results.push_back(result.get_string())
	
	if results.size() > 0:
		print ("COMMAND ENTERED: ", results)
		
		match results[0]:
			"level_up":
				log_text(results[0])
				PlayerManager.current_exp = 0
				PlayerManager.level_up()
				emit_signal("triggered_new_menu")
				pass

			"set_time":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					TimeManager.current_time = int(results[1])
				
				elif results.size() > 1:
					log_text("Invalid number of seconds")

				else:
					log_text("No value specified")
				pass

			"add_time":
				if results.size() > 1  and  results[1].is_valid_integer():
					log_text(text)
					TimeManager.current_time += int(results[1])
				
				elif results.size() > 1:
					log_text("Invalid number of seconds")

				else:
					log_text("No value specified")
				pass

			_:
				log_text("Command not recognized: \'" + results[0] + "\'\n")
				pass
		
	else:
		log_text("Invalid formatting: \'" + text + "\'\n")



func _ready():
	
	regex.compile("[^\\(\\)\\,\\s]+")
